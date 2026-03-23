# Mission 01: Llama 3.2 Relay V1

Status:
- concluded

Start:
- 2026-03-23

## Goal

Build the first local relay layer using `llama3.2` as the local model.

The point is not to build a genius.
The point is to build a cheap, pleasant first layer that can:
- handle basic conversation
- understand user intent well enough
- decide when to answer locally
- decide when to relay to Codex
- decide when to escalate to a frontier model first

## Why `llama3.2` First

We are choosing `llama3.2` first because:
- conversation feel matters
- intent reading matters
- the local layer should feel like a real front desk
- strict routing can be improved with prompting if needed

We are not optimizing for benchmark purity first.
We are optimizing for real interaction feel.

## Target Routing Lanes

- `local-answer`
- `codex-relay`
- `frontier-think`
- `block`

## What `local-answer` Means

Allowed examples:
- greetings
- simple chat
- short summaries
- quick status replies
- low-risk conversational help

Not allowed:
- commits by default
- destructive shell actions
- vague high-stakes decisions
- pretending to do execution work that should go to Codex

## First-Day Scope

Current pass:

1. install/check Ollama in WSL
2. pull and run `llama3.2`
3. write the first relay prompt
4. test on real message examples from the actual SirClaw flow
5. check whether `llama3.2` can cleanly choose:
   - answer locally
   - relay to Codex
   - escalate to frontier
   - block

Done so far:
- Ollama installed user-local in WSL
- `llama3.2` pulled successfully
- GPU path detected the GTX 970 but crashed on repeated real inference
- CPU path works technically
- trivial CPU smoke test returned `READY`
- CPU run was judged unacceptable because it choked the whole machine
- Windows-native Ollama was installed and tested
- Windows-native server started, but still selected CPU instead of GPU

Immediate next:
- do not continue with `llama3.2` CPU as the main path
- test smaller / lighter options
- reconsider runtime strategy before prompt work goes deeper
- if staying with Ollama, skip more stock-install retries and move straight to custom-build investigation

Pivot note:
- if the user-tested Qwen 2B path really runs on GPU, it becomes the next live candidate immediately
- runtime fit now outranks prior preference for `llama3.2`

Final conclusion:
- `llama3.2` is not the path on this machine
- keep this mission as historical context only

## First Evaluation Set

Test examples should include:
- normal greeting
- "what happened?"
- "tell Codex to rerun bridge, no commit"
- "help me think through architecture"
- "commit everything"
- "summarize current status"
- "just talk to me for a second"

## Success Criteria

This mission succeeds if:
- local replies feel natural enough
- route selection is mostly correct
- obvious dangerous asks do not slip through
- simple conversational turns stay local
- Codex/frontier only wake up when they should

## Failure Signs

We should switch or compare models if `llama3.2`:
- routes too loosely
- ignores guardrails
- feels weak at intent recognition
- answers when it should escalate
- escalates too much and defeats the cost goal
- is operationally too heavy for the machine even when output quality is fine

## If It Struggles

Second model to compare:
- `qwen2.5:3b-instruct-q4_K_M`

Reason:
- probably stricter router
- good fallback if `llama3.2` is nicer but too sloppy

## Final Reminder

The local model is the front desk.
Codex is execution.
Frontier model is deep thinking.

Keep those roles clean.
