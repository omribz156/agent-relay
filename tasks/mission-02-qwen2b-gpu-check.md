# Mission 02: Qwen 2B GPU Check

Status:
- concluded

## Goal

Validate the Qwen 2B-class model that reportedly already runs on this machine with GPU.

The question is not "is it the smartest model?"
The question is:
- does it run cleanly
- does it stay light enough
- is it good enough for local-answer / codex-relay / frontier-think / block

## Why This Mission Exists

`llama3.2` lost on runtime reality:
- WSL GPU path crashed
- Windows stock path stayed on CPU
- CPU path was too heavy

So now the best candidate is the one that already seems to work.

## Success Criteria

- model loads on GPU without drama
- no machine-choking CPU fallback
- route choices are mostly sane
- basic chat tone is acceptable

## First Result

- `qwen3.5:2b` pulled successfully
- model loaded in WSL with mixed CPU/GPU usage
- Ollama reported about `44%/56% CPU/GPU`
- runner offloaded `24/25` layers to GPU
- runtime looks viable
- first exact-output obedience test was messy, so behavior still needs evaluation

## Router Pass

- added prompt: `prompts/qwen-router-v1.md`
- added router entrypoint: `scripts/route-message.sh`
- added eval harness: `scripts/eval-router.sh`
- added starter cases: `tests/router-cases.tsv`

Observed result:
- starter route set passed `8/8`
- routes covered:
  - `local-answer`
  - `codex-relay`
  - `frontier-think`
  - `block`

Current judgment:
- runtime: good enough
- routing: promising
- next need: harder real-world prompts, not just toy checks

## Harder Eval

- added `tests/router-cases-hard.tsv`
- first pass scored `14/15`
- issue found:
  - router answered a live status-inspection ask locally
- second pass scored `14/15`
- issue found:
  - router over-escalated a simple known-decision confirmation
- after prompt tightening, hard set scored `15/15`

Current judgment now:
- runtime: viable
- routing: genuinely promising
- next step: connect this to a real SirClaw-style loop, not just eval files

Final conclusion:
- router harness succeeded
- live OpenClaw local-answer deployment failed on runtime stability
- keep the artifacts, stop the live rollout on this machine

## First Checks

1. confirm exact model name
2. confirm actual GPU usage, not fake vibes
3. run 5 to 10 relay-style prompts
4. judge:
   - usable now
   - usable with prompt tuning
   - not good enough

## Reminder

Stable and good-enough wins.
Do not lose a week worshipping parameter counts.
