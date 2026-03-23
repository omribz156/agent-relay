# Agent Relay

Cheap local-first relay layer for SirClaw / OpenClaw / Codex workflows.

Goal:
- use a local model for cheap chat, routing, and small task handling
- escalate only when needed
- keep frontier model spend for real reasoning
- keep Codex focused on execution work

## What This Repo Is

This repo is not tied to Navi only.

It is the wider control layer for:
- Telegram -> SirClaw / OpenClaw
- local router model in WSL
- Codex execution bridge
- frontier/API escalation when tasks are genuinely complex

## Core Flow

```text
Telegram -> SirClaw
           |
           v
   local router (WSL model)
 "local-answer / codex-relay /
  frontier-think / block"
           |
   +-------+--------+---------+
   |       |        |         |
   v       v        v         v
 local   Codex    API       ask user /
 reply   runs     thinks    refuse
                   first
```

## Start Here

- read [docs/bootstrap.md](docs/bootstrap.md)
- read [docs/architecture.md](docs/architecture.md)
- read [docs/model-strategy.md](docs/model-strategy.md)

## First Build Goal

Phase one should be humble:
- install a local model runtime in WSL
- test one small model
- classify messages into a few lanes reliably
- keep dangerous or ambiguous actions out of the local layer

## Current Recommendation

Hardware reality:
- GTX 970, 4GB VRAM
- i5-6600K
- limited WSL memory headroom

So first model work should target:
- 1B to 3B class
- routing and light conversation only

Runtime blocker right now:
- GPU path for `llama3.2` crashes on this machine
- CPU path technically runs, but it chokes the whole machine

Current best lead:
- `qwen3.5:2b` does run in WSL with mixed CPU/GPU usage
- early structured-router test passed `8/8` on the starter set
- OpenClaw v1 router plugin is now wired to use that classifier before model selection
- current live behavior is narrow on purpose:
  - `local-answer` -> switch to `ollama/qwen3.5:2b`
  - everything else -> stay on frontier default
- runnable OpenClaw plugin copy lives under `/home/omri/.openclaw/extensions/relay-router`
- source still lives in this repo under `extensions/relay-router`
- so local inference now looks viable enough to keep pushing
- next phase should focus on harder real prompts and guardrails, not more model roulette

Experiment end-state:
- router harness work is good
- live OpenClaw local-answer path is not stable enough on this machine
- current recommendation is to keep OpenClaw on frontier/API for now
- full write-up: [docs/openclaw-local-relay-experiment.md](docs/openclaw-local-relay-experiment.md)

## Repo Layout

- `docs/`
  - architecture, model strategy, setup notes
- `scripts/`
  - runtime and routing helpers
- `tasks/`
  - active planning/execution notes

Useful deploy command:

```bash
cd /mnt/d/projects/agent-relay
./scripts/deploy-openclaw-router.sh --restart
```

Warm helper:

```bash
cd /mnt/d/projects/agent-relay
./scripts/warm-router.sh
```

Temporary local-only test switch:
- set `plugins.entries.relay-router.config.forceLocalTestMode` to `true`
- keeps non-block turns on local Ollama while tuning chat behavior
