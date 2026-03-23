#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/mnt/d/projects/agent-relay"
CASES_FILE="${1:-$ROOT_DIR/tests/router-cases.tsv}"
ROUTER_SCRIPT="$ROOT_DIR/scripts/route-message.sh"

if [[ ! -f "$CASES_FILE" ]]; then
  echo "missing cases file: $CASES_FILE"
  exit 1
fi

pass_count=0
total_count=0

while IFS=$'\t' read -r expected message; do
  [[ -z "${expected:-}" ]] && continue
  [[ "${expected:0:1}" == "#" ]] && continue
  total_count=$((total_count + 1))

  result="$("$ROUTER_SCRIPT" --json "$message")"
  actual="$(printf '%s' "$result" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const o=JSON.parse(s);process.stdout.write(o.route||"");});')"

  if [[ "$actual" == "$expected" ]]; then
    status="PASS"
    pass_count=$((pass_count + 1))
  else
    status="FAIL"
  fi

  printf '%s\twant=%s\tgot=%s\tmsg=%s\n' "$status" "$expected" "$actual" "$message"
done <"$CASES_FILE"

printf '\nscore: %s/%s\n' "$pass_count" "$total_count"
