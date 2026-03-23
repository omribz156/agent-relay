#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="/mnt/d/projects/agent-relay"
TARGET_DIR="/home/omri/.openclaw/extensions/relay-router"
RESTART_MODE="${1:-}"

mkdir -p "$TARGET_DIR/scripts" "$TARGET_DIR/prompts"

cp "$ROOT_DIR/extensions/relay-router/index.js" "$TARGET_DIR/index.js"
cp "$ROOT_DIR/extensions/relay-router/openclaw.plugin.json" "$TARGET_DIR/openclaw.plugin.json"
cp "$ROOT_DIR/extensions/relay-router/package.json" "$TARGET_DIR/package.json"
cp "$ROOT_DIR/scripts/route-message.sh" "$TARGET_DIR/scripts/route-message.sh"
cp "$ROOT_DIR/scripts/warm-router.sh" "$TARGET_DIR/scripts/warm-router.sh"
cp "$ROOT_DIR/prompts/qwen-router-v1.md" "$TARGET_DIR/prompts/qwen-router-v1.md"

chmod 755 \
  "$TARGET_DIR" \
  "$TARGET_DIR/scripts" \
  "$TARGET_DIR/prompts" \
  "$TARGET_DIR/index.js" \
  "$TARGET_DIR/openclaw.plugin.json" \
  "$TARGET_DIR/package.json" \
  "$TARGET_DIR/scripts/route-message.sh" \
  "$TARGET_DIR/scripts/warm-router.sh" \
  "$TARGET_DIR/prompts/qwen-router-v1.md"

echo "deployed relay-router to $TARGET_DIR"

if [[ "$RESTART_MODE" == "--restart" ]]; then
  systemctl --user restart openclaw-gateway.service
  echo "restarted openclaw-gateway.service"
fi
