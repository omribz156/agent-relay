# AGENTS.md

Work style:
- direct
- low-ego
- small steps
- local-first where sensible

## Scope

This repo owns the relay/orchestration layer, not product code for one app.

Think in terms of:
- message intake
- route selection
- escalation
- execution handoff
- status return

## Main Rule

Do not let the local model cosplay as a frontier reasoner.

Use the local model for:
- cheap chat
- intent classification
- short summaries
- shaping a task for Codex
- deciding whether to escalate

Use stronger models for:
- architecture
- ambiguous planning
- hard debugging
- high-stakes decisions

## Target Routing Lanes

- `local-answer`
- `codex-relay`
- `frontier-think`
- `block`

## Safety

Default dangerous or unclear asks to:
- `frontier-think`
or
- `block`

Do not give local models commit/destructive/admin powers by default.
