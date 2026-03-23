# Bootstrap

Purpose:
- fast entry
- stable system picture
- minimal rereading

## What This System Does

This repo is the control layer above local chat and below expensive reasoning.

It should answer:
- can the local model handle this?
- should Codex execute this?
- should a frontier model think first?
- should the system refuse or ask the user?

## Read Order

1. `README.md`
2. `AGENTS.md`
3. `docs/architecture.md`
4. `docs/model-strategy.md`
5. relevant script or active task only

## Current Stance

- local model should be cheap and small
- routing quality matters more than local cleverness
- Codex remains the execution layer for repo/script work
- frontier model remains the high-horizon reasoning lane

## Current Machine Assumptions

- WSL2
- NVIDIA GTX 970
- 4GB VRAM
- local inference must stay modest

## Machine Reality Now

- Ollama `0.18.2` installed user-local in WSL
- local binary path: `/home/omri/.local/bin/ollama`
- runtime session name when used: `tmux` session `relay-ollama`
- `llama3.2` pulled successfully
- GTX 970 is detected by Ollama, but repeated real `llama3.2` GPU inference crashes the runner
- CPU mode works technically, but it chokes the whole machine in practice
- current stance: do not use `llama3.2` CPU mode as a normal relay path on this box
- GPU can be revisited later, but is not trusted yet
- likely cause: prebuilt Ollama CUDA path is not really workable on this Maxwell `compute 5.2` card
- Windows-native Ollama was also tested; it booted, but selected `cpu` instead of GPU
- `qwen3.5:2b` on WSL did load and run with mixed CPU/GPU usage

## Important Constraint

Right now this machine has no acceptable `llama3.2` runtime lane:
- GPU lane: unstable
- Windows-native prebuilt lane: boots, but no usable GPU detected by Ollama
- CPU lane: usable only as a brief smoke test, not as a working setup

That means:
- do not treat Ollama + `llama3.2` as ready for background relay duty
- next experiments should bias toward smaller models, lighter runtimes, or different settings
- if Ollama-on-GPU remains the goal, likely next try is Windows-native Ollama or a custom build targeting `sm_52`

Current best lead:
- `qwen3.5:2b` in WSL
- observed load split was about `44%/56% CPU/GPU`
- runner offloaded `24/25` layers to GPU on this GTX 970
- OpenClaw now has a v1 router plugin that uses the local classifier pre-model
- current v1 rule:
  - `local-answer` -> Ollama/Qwen
  - all other routes -> default frontier model

## OpenClaw Deployment Note

- OpenClaw blocks plugins from world-writable paths
- repo paths under `/mnt/d/...` count as world-writable on this machine
- so the runnable plugin copy must live under `/home/omri/.openclaw/extensions/relay-router`
- source of truth still lives in this repo:
  - `extensions/relay-router`
  - `scripts/route-message.sh`
  - `prompts/qwen-router-v1.md`
- if the plugin code changes, sync the runtime copy before restarting OpenClaw
- deploy helper:
  - `./scripts/deploy-openclaw-router.sh --restart`
- warm helper:
  - `./scripts/warm-router.sh`
- current warm stance:
  - router timeout lifted to `45s`
  - router keep-alive lifted to `30m`
  - `start-ollama.sh auto` tries one cheap warm call after boot
- temporary testing switch exists:
  - `forceLocalTestMode: true`
  - use only while tuning local chat behavior
  - turn it back off after the experiment

## Near-Term Goal

Build a reliable first router before trying to build a tiny genius.

## Current Conclusion

- local router research: worth keeping
- live OpenClaw local-answer mode on this machine: not good enough
- revert OpenClaw to normal frontier/API path for daily use
- detailed experiment log:
  - `docs/openclaw-local-relay-experiment.md`
