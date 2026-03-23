# OpenClaw Local Relay Experiment

Status:
- concluded
- local live path scrapped on current machine

Date:
- 2026-03-23

## Goal

Try a local-first OpenClaw path:
- easy/basic chat stays local
- harder work escalates to frontier
- Codex remains execution layer later

## What We Built

Repo-side assets:
- `prompts/qwen-router-v1.md`
- `scripts/route-message.sh`
- `scripts/eval-router.sh`
- `scripts/start-ollama.sh`
- `scripts/warm-router.sh`
- `scripts/deploy-openclaw-router.sh`
- `extensions/relay-router`

OpenClaw-side integration:
- native plugin hook path
- pre-model routing plugin
- runtime plugin copy under `~/.openclaw/extensions/relay-router`

## What Worked

### Runtime facts

- `llama3.2` on this box was a dead end
  - WSL GPU path crashed
  - Windows stock path stayed on CPU
  - CPU path choked the machine

- `qwen3.5:2b` did run in WSL Ollama
  - mixed CPU/GPU load
  - `24/25` layers offloaded to GPU
  - workable for router harness tests

### Router harness

- starter eval set passed `8/8`
- harder messy set passed `15/15`
- prompt tuning improved:
  - live-state asks should not stay local
  - known-summary asks can stay local

### OpenClaw integration

- native plugin path works
- `before_model_resolve` hook is enough for v1 routing
- local lane could successfully:
  - classify turn
  - override provider to `ollama`
  - override model to `qwen3.5:2b`

## What Failed

### Path / trust reality

- OpenClaw rejects world-writable plugin paths
- repo path under `/mnt/d/...` was blocked
- runtime plugin copy had to live in `~/.openclaw/extensions/relay-router`

### Auth plumbing

- local lane first failed because Ollama auth profile was missing
- fix was straightforward
- not the real blocker

### Live local-answer path

The real blocker was live generation inside OpenClaw:
- local router worked
- local-only test mode worked
- frontier bypass worked
- but actual local reply turns kept failing under real OpenClaw load

Observed failure patterns:
- `LLM request failed: network connection error`
- local Ollama session died mid-run
- local turn timed out even for tiny user messages
- Qwen runtime under full OpenClaw prompt/context load was not stable enough on this machine

## Important Conclusion

For this exact machine:
- local router harness: yes
- live OpenClaw local-answer runtime: no

Meaning:
- the repo work is still useful
- the OpenClaw live local path should stay disabled on this computer
- revisit on a stronger machine later

## Reusable Assets Kept

Keep in repo:
- router prompt
- eval harness
- Ollama helper scripts
- OpenClaw plugin source
- experiment notes

These are still a good base for a stronger machine later.

## Final Recommendation

Current machine recommendation:
- OpenClaw returns to frontier/API-only operation
- local relay remains a research repo, not active production path

Later machine recommendation:
- retry live OpenClaw local-answer path
- start from this repo assets, not from zero
