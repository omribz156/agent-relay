# Model Strategy

## Current Hardware Reality

Observed machine facts:
- GPU: GTX 970
- VRAM: 4GB
- Compute capability: 5.2
- CPU: i5-6600K
- WSL memory headroom is limited

## What This Means

The local layer should start with small models only.

Target role:
- router
- short conversational helper
- lightweight summarizer

Not target role:
- deep coder
- long-horizon planner
- high-confidence autonomous operator

## First Model Candidates

### Best first router candidate

- `qwen2.5:3b-instruct-q4_K_M`

Why:
- strong structured output
- good for tags/routes/JSON-ish answers
- realistic fit for this hardware class

### Best fallback / compare candidate

- `llama3.2`

Why:
- widely available
- good assistant feel
- useful comparison point

### Tiny option for ultra-cheap routing

- `llama3.2` 1B class equivalent if available in target runtime

Use when:
- the 3B path is too slow or flaky
- task is only route classification

## Route Output Format

The local router should output something like:

```text
ROUTE: local-answer | codex-relay | frontier-think | block
WHY: one short line
TASK: short rewrite if needed
GUARDRAIL: optional
```

## First Evaluation Set

Test the local model on real examples:
- casual greeting
- "check whether Codex finished"
- "tell Codex to rerun bridge, no commit"
- "help me think through architecture"
- "please commit everything"

Expected routes:
- `local-answer`
- `local-answer` or `codex-relay`
- `codex-relay`
- `frontier-think`
- `block`

## Success Criteria

- local model classifies reliably
- direct local replies feel natural enough
- Codex/frontier spend drops on routine turns
- dangerous asks do not slip through the cheap lane
