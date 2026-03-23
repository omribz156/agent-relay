#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${RELAY_ROOT_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
MODEL="${ROUTER_MODEL:-qwen3.5:2b}"
PROMPT_FILE="${ROUTER_PROMPT_FILE:-$ROOT_DIR/prompts/qwen-router-v1.md}"
OLLAMA_URL="${OLLAMA_URL:-http://127.0.0.1:11434/api/generate}"
KEEP_ALIVE="${ROUTER_KEEP_ALIVE:-30m}"
OUTPUT_MODE="pretty"

if [[ "${1:-}" == "--json" ]]; then
  OUTPUT_MODE="json"
  shift
fi

if [[ "${1:-}" == "--model" ]]; then
  MODEL="${2:-}"
  shift 2
fi

if [[ $# -gt 0 ]]; then
  MESSAGE="$*"
else
  MESSAGE="$(cat)"
fi

if [[ -z "${MESSAGE// }" ]]; then
  echo "usage: $0 [--json] [--model model] \"message\""
  exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "missing prompt file: $PROMPT_FILE"
  exit 1
fi

if ! curl -fsS http://127.0.0.1:11434/api/version >/dev/null 2>&1; then
  echo "ollama server not running on 127.0.0.1:11434"
  exit 1
fi

SYSTEM_PROMPT="$(cat "$PROMPT_FILE")"

RAW_RESPONSE="$(
  SYSTEM_PROMPT="$SYSTEM_PROMPT" \
  MESSAGE="$MESSAGE" \
  MODEL="$MODEL" \
  node <<'EOF' | curl -fsS "$OLLAMA_URL" -H 'Content-Type: application/json' -d @-
const system = process.env.SYSTEM_PROMPT || '';
const message = process.env.MESSAGE || '';
const model = process.env.MODEL || 'qwen3.5:2b';
const schema = {
  type: 'object',
  properties: {
    route: { type: 'string', enum: ['local-answer', 'codex-relay', 'frontier-think', 'block'] },
    why: { type: 'string' },
    task: { type: 'string' },
    guardrail: { type: 'string' },
    reply: { type: 'string' }
  },
  required: ['route', 'why', 'task', 'guardrail', 'reply']
};
process.stdout.write(JSON.stringify({
  model,
  system,
  prompt: message,
  format: schema,
  stream: false,
  think: false,
  keep_alive: process.env.KEEP_ALIVE || '30m',
  options: {
    temperature: 0,
    top_p: 0.9,
    num_ctx: 2048
  }
}));
EOF
)"

PARSED_RESPONSE="$(
  printf '%s' "$RAW_RESPONSE" | node -e '
let raw = "";
process.stdin.on("data", chunk => raw += chunk);
process.stdin.on("end", () => {
  const outer = JSON.parse(raw);
  const inner = JSON.parse(outer.response);
  process.stdout.write(JSON.stringify(inner));
});
'
)"

if [[ "$OUTPUT_MODE" == "json" ]]; then
  printf '%s\n' "$PARSED_RESPONSE"
  exit 0
fi

printf '%s' "$PARSED_RESPONSE" | node -e '
let raw = "";
process.stdin.on("data", chunk => raw += chunk);
process.stdin.on("end", () => {
  const o = JSON.parse(raw);
  console.log(`ROUTE: ${o.route}`);
  console.log(`WHY: ${o.why}`);
  console.log(`TASK: ${o.task}`);
  console.log(`GUARDRAIL: ${o.guardrail}`);
  console.log(`REPLY: ${o.reply}`);
});
'
