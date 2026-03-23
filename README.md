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

## Current Status

This repo contains useful research and working tooling.

It does not currently mean:
- "the whole local-first stack is production-ready"
- "OpenClaw should run locally on this machine full-time"

Current recommendation:
- keep OpenClaw on normal frontier/API mode on this computer
- keep this repo as the base for a later retry on stronger hardware

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

## What We Tried

We tested two layers of the idea:

1. local router harness
2. live OpenClaw local-answer path

### Router Harness

This part worked well.

Built here:
- `prompts/qwen-router-v1.md`
- `scripts/route-message.sh`
- `scripts/eval-router.sh`
- `tests/router-cases.tsv`
- `tests/router-cases-hard.tsv`

Results:
- starter eval passed `8/8`
- harder eval passed `15/15`

Meaning:
- a small local model can classify turns usefully on this machine
- router research was not wasted

### Live OpenClaw Local-Answer Path

This part did not hold up on this machine.

We built:
- an OpenClaw plugin under `extensions/relay-router`
- a runtime deploy path into `~/.openclaw/extensions/relay-router`
- warm/deploy helpers for Ollama and the router

What worked:
- OpenClaw plugin integration
- pre-model routing hook
- model/provider override
- local-only test mode

What failed:
- local reply turns were not stable enough under full OpenClaw load
- Ollama/Qwen kept timing out or dying mid-turn
- even tiny chat messages could fail in live use

So the important split is:
- local router research: yes
- live local-answer OpenClaw runtime on this box: no

## Hardware Reality

Hardware reality:
- GTX 970, 4GB VRAM
- i5-6600K
- limited WSL memory headroom

So first model work should target:
- 1B to 3B class
- routing and light conversation only

Known runtime reality:
- GPU path for `llama3.2` crashes on this machine
- CPU path technically runs, but it chokes the whole machine

Current best lead:
- `qwen3.5:2b` does run in WSL with mixed CPU/GPU usage
- it is still the best local router candidate we found here
- it is not a reliable live OpenClaw local-answer engine on this machine

## Final Recommendation

For the current computer:
- keep OpenClaw on frontier/API
- do not run the local-answer live path as daily infrastructure
- keep the router assets and experiment notes
- retry later on a stronger machine

Full write-up:
- [docs/openclaw-local-relay-experiment.md](docs/openclaw-local-relay-experiment.md)

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

## Important Note

OpenClaw has already been returned to its normal non-experimental baseline on
this machine.

So this repo currently represents:
- research
- tooling
- the next-machine starting point

Not an active local-answer deployment.
