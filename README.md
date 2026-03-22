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

## Repo Layout

- `docs/`
  - architecture, model strategy, setup notes
- `scripts/`
  - runtime and routing helpers
- `tasks/`
  - active planning/execution notes
