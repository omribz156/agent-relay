# Architecture

## Overview

The system is a hybrid relay:

```text
User
-> SirClaw / OpenClaw
-> local router
-> one of:
   - local-answer
   - codex-relay
   - frontier-think
   - block
-> response back to user
```

## Lane Meanings

### `local-answer`

Use for:
- greetings
- short status checks
- tiny summaries
- low-risk plain conversation

The local model may answer directly.

### `codex-relay`

Use for:
- script runs
- file checks
- repo operations
- bridge/status actions
- concrete execution tasks

Flow:
- SirClaw turns the ask into a short task
- Codex executes
- SirClaw returns the result

### `frontier-think`

Use for:
- ambiguous asks
- planning
- architecture
- debugging with uncertainty
- product/system tradeoffs

Flow:
- stronger model thinks first
- SirClaw turns the result into a sharper mission
- Codex executes if needed

### `block`

Use for:
- destructive actions
- secret-sensitive actions
- unclear permission
- unsafe commands
- requests outside current policy

## Design Principles

- cheap first
- safe by default
- escalate early when ambiguity is real
- execution and reasoning stay separate when useful
- logs/status should be human-readable

## Anti-Goal

Do not build one giant assistant that pretends every request is the same kind of problem.
