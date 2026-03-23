#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="/mnt/d/projects/agent-relay"

if ! curl -fsS http://127.0.0.1:11434/api/version >/dev/null 2>&1; then
  echo "ollama server not running on 127.0.0.1:11434"
  exit 1
fi

ROUTER_KEEP_ALIVE="${ROUTER_KEEP_ALIVE:-30m}" \
  "$ROOT_DIR/scripts/route-message.sh" --json "hey, you here" >/dev/null

echo "router warm"
