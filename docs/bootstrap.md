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

## Near-Term Goal

Build a reliable first router before trying to build a tiny genius.
