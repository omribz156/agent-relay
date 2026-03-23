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

### Next live candidate

- Qwen 2B-class model
- user-tested candidate: `qwen 3.5 2B`

Why:
- already reported to run on this machine with GPU
- much better sign than theoretical bigger models that fail in practice
- good fit for cheap front-desk routing if behavior is solid

Reality:
- working GPU runtime matters more than parameter bragging
- if a 2B model runs cleanly on GPU, it beats a 3B+ model that falls back to CPU or crashes
- `qwen3.5:2b` passed the first runtime test on this box

Working theory:
- the prebuilt Ollama CUDA path likely does not properly support Maxwell `compute 5.2`
- this matches older upstream reports around `5.0` / `5.2` cards failing at runtime even when detection succeeds
- Windows-native Ollama did not save it; on this machine it started, but reported `inference compute = cpu`

New stance:
- bias toward models already proven to run on this exact box
- only chase bigger parameter counts after runtime stability is confirmed
- `qwen3.5:2b` is now the front-runner

### Best fallback / compare candidate

- `qwen2.5:3b-instruct-q4_K_M`

Why:
- probably stricter router
- better if `llama3.2` gets too loose on routing

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

## Current Runtime Note

Observed smoke test:
- `ollama run llama3.2 "Reply with exactly: READY"` worked in CPU mode
- wall clock was about 8 seconds on this machine

Interpretation:
- proves basic compatibility only
- not viable as a background front desk on this machine
- treat this as a blocker, not as a green light

Practical next options:
- custom-build Ollama / llama backend with explicit `sm_52` targeting
- test a different runtime entirely for local GPU inference
- if trying Windows again, treat it as custom-config / custom-build territory, not "stock install should just work"
- first practical move: validate the Qwen 2B GPU-working path on real relay prompts

Observed Qwen runtime facts:
- WSL + Ollama + GTX 970 did load `qwen3.5:2b`
- `ollama ps` reported `44%/56% CPU/GPU`
- Ollama logs showed `24/25` layers offloaded to GPU
- model weights split was about `1.4 GiB` on GPU and `1.6 GiB` on CPU
- exact-output obedience was sloppy on the first tiny test, so prompt/behavior tuning still matters

Prompting result:
- switching from raw `ollama run` to structured API routing improved behavior a lot
- first tiny router set passed `8/8`
- good sign for relay classification
- still only a toy set, so not victory-lap territory yet

Harder eval result:
- messy Telegram-style starter set passed `15/15` after two prompt refinements
- main fixes were:
  - current live repo/status questions should relay
  - already-known decision summaries should stay local
- this is strong enough to keep building on Qwen instead of reopening model roulette

## Live Integration Status

Current OpenClaw integration is intentionally narrow:
- router runs before model selection
- if route is `local-answer`, switch to `ollama/qwen3.5:2b`
- otherwise stay on the default frontier model

Not wired yet in OpenClaw v1:
- direct `codex-relay`
- hard `block` handling
- rich multi-lane orchestration inside the gateway itself

Why:
- smallest real proof first
- semantic local-vs-frontier switch without proxy sprawl
- keep the more opinionated Codex/block behavior for phase 2

## Current Conclusion

`qwen3.5:2b` is good enough as a local router candidate.

It is not good enough, on this machine and runtime path, as a reliable live
OpenClaw local-answer engine.

So the split is now:
- keep Qwen router research
- pause live OpenClaw local-answer deployment
- revisit on stronger hardware later
