#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
SESSION="${OLLAMA_SESSION_NAME:-relay-ollama}"
ROOT_DIR="/mnt/d/projects/agent-relay"
OLLAMA_BIN="${OLLAMA_BIN:-/home/omri/.local/bin/ollama}"
WARM_MODEL="${WARM_ROUTER_AFTER_START:-1}"

if [[ ! -x "$OLLAMA_BIN" ]]; then
  echo "missing ollama binary at $OLLAMA_BIN"
  exit 1
fi

case "$MODE" in
  cpu)
    RUN_CMD="CUDA_VISIBLE_DEVICES= OLLAMA_LLM_LIBRARY=cpu $OLLAMA_BIN serve"
    ;;
  auto)
    RUN_CMD="$OLLAMA_BIN serve"
    ;;
  *)
    echo "usage: $0 [cpu|auto]"
    echo "note: cpu = brief smoke test only; auto = experimental GPU path"
    exit 1
    ;;
esac

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux kill-session -t "$SESSION"
fi

tmux new-session -d -s "$SESSION" -c "$ROOT_DIR" "$RUN_CMD"
sleep 2

echo "started $SESSION"
echo "mode: $MODE"
echo "inspect: tmux capture-pane -pt $SESSION -S -40"

if [[ "$WARM_MODEL" == "1" ]]; then
  sleep 2
  if "$ROOT_DIR/scripts/warm-router.sh" >/dev/null 2>&1; then
    echo "router: warm"
  else
    echo "router: warm skipped"
  fi
fi
