# Scripts

Planned script areas:
- runtime install/setup
- local router prompt tests
- message routing
- bridge integration
- status inspection

Current script:
- `start-ollama.sh`
  - starts local Ollama in tmux session `relay-ollama`
  - no default mode on purpose
  - `cpu` exists only for brief smoke tests
  - `auto` exists for retrying GPU detection later
  - both modes are currently experimental on this machine
- `route-message.sh`
  - sends one message to local Ollama router
  - default model: `qwen3.5:2b`
  - uses structured JSON output
- `eval-router.sh`
  - runs a tiny route evaluation set from `tests/router-cases.tsv`
- `warm-router.sh`
  - warms the local Qwen router model
- `deploy-openclaw-router.sh`
  - syncs runtime plugin copy into `~/.openclaw/extensions/relay-router`

Current conclusion:
- these scripts are good research tools
- they are not an endorsement of the current machine as a stable live OpenClaw local runtime

Keep scripts small.

One script per clear job.
