import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { t as definePluginEntry } from "/home/omri/.nvm/versions/node/v24.14.0/lib/node_modules/openclaw/dist/plugin-entry-BNczxv7M.js";

const execFileAsync = promisify(execFile);

const DEFAULTS = {
  scriptPath: "/mnt/d/projects/agent-relay/scripts/route-message.sh",
  routerModel: "qwen3.5:2b",
  ollamaUrl: "http://127.0.0.1:11434/api/generate",
  localProvider: "ollama",
  localModel: "qwen3.5:2b",
  timeoutMs: 45_000,
  logRoutes: true,
  forceLocalTestMode: false
};

function getString(value, fallback) {
  return typeof value === "string" && value.trim() ? value.trim() : fallback;
}

function getNumber(value, fallback) {
  return typeof value === "number" && Number.isFinite(value) && value > 0 ? value : fallback;
}

function getBoolean(value, fallback) {
  return typeof value === "boolean" ? value : fallback;
}

function resolveSettings(pluginConfig) {
  return {
    scriptPath: getString(pluginConfig.scriptPath, DEFAULTS.scriptPath),
    routerModel: getString(pluginConfig.routerModel, DEFAULTS.routerModel),
    ollamaUrl: getString(pluginConfig.ollamaUrl, DEFAULTS.ollamaUrl),
    localProvider: getString(pluginConfig.localProvider, DEFAULTS.localProvider),
    localModel: getString(pluginConfig.localModel, DEFAULTS.localModel),
    timeoutMs: getNumber(pluginConfig.timeoutMs, DEFAULTS.timeoutMs),
    logRoutes: getBoolean(pluginConfig.logRoutes, DEFAULTS.logRoutes),
    forceLocalTestMode: getBoolean(pluginConfig.forceLocalTestMode, DEFAULTS.forceLocalTestMode)
  };
}

async function classifyPrompt(settings, prompt) {
  const { stdout } = await execFileAsync(
    "bash",
    [settings.scriptPath, "--json", prompt],
    {
      timeout: settings.timeoutMs,
      maxBuffer: 1024 * 1024,
      env: {
        ...process.env,
        ROUTER_MODEL: settings.routerModel,
        OLLAMA_URL: settings.ollamaUrl,
        ROUTER_KEEP_ALIVE: "30m",
        RELAY_ROOT_DIR: "/home/omri/.openclaw/extensions/relay-router"
      }
    }
  );
  return JSON.parse(stdout);
}

var relay_router_default = definePluginEntry({
  id: "relay-router",
  name: "Relay Router",
  description: "Routes simple prompts to a local Ollama model before frontier fallback.",
  configSchema: {
    type: "object",
    additionalProperties: false,
    properties: {
      scriptPath: { type: "string" },
      routerModel: { type: "string" },
      ollamaUrl: { type: "string" },
      localProvider: { type: "string" },
      localModel: { type: "string" },
      timeoutMs: { type: "integer", minimum: 1000 },
      logRoutes: { type: "boolean" },
      forceLocalTestMode: { type: "boolean" }
    }
  },
  register(api) {
    const settings = resolveSettings(api.pluginConfig ?? {});

    api.on("before_model_resolve", async (event) => {
      const prompt = typeof event?.prompt === "string" ? event.prompt.trim() : "";
      if (!prompt) return;

      try {
        const result = await classifyPrompt(settings, prompt);
        if (settings.logRoutes) {
          api.logger.info(
            `[relay-router] route=${result.route ?? "unknown"} provider=${result.route === "local-answer" ? settings.localProvider : "default"}`
          );
        }
        if (settings.forceLocalTestMode && result?.route !== "block") {
          if (settings.logRoutes) {
            api.logger.info("[relay-router] forceLocalTestMode=on -> keeping turn on local model");
          }
          return {
            providerOverride: settings.localProvider,
            modelOverride: settings.localModel
          };
        }
        if (result?.route !== "local-answer") return;
        return {
          providerOverride: settings.localProvider,
          modelOverride: settings.localModel
        };
      } catch (error) {
        api.logger.warn(`[relay-router] router fallback to default model: ${error instanceof Error ? error.message : String(error)}`);
        return;
      }
    });
  }
});

export { relay_router_default as default };
