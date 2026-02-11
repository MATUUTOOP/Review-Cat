# CopilotRunnerSystem

## Overview

`CopilotRunnerSystem` is responsible for invoking GitHub Copilot CLI and capturing outputs in a reproducible way.

It is the boundary between ReviewCat logic and the external agent.

## Requirements

1. Must run Copilot CLI in programmatic mode for persona prompts.
2. Must capture stdout/stderr and exit code.
3. Must write prompt ledger entries for each invocation.
4. Must support record/replay mode for tests.
5. Must enforce tool allow/deny policy.

## Interfaces

Inputs:

- `PromptRecord`
- policy (allow/deny lists)

Outputs:

- raw output text
- parsed JSON (best effort)
- ledger entry

Ledger files:

- `ledger/copilot_prompts.jsonl`
- `ledger/copilot_raw_outputs/<call_id>.txt`

## Acceptance criteria

- Given a prompt, system produces a raw output and a ledger record.
- In replay mode, system returns fixture output without calling Copilot CLI.
- Denied tools are never requested in programmatic options.

## Test cases

- Replay mode returns fixture.
- Ledger entry is written with correct timestamps.
- Policy merges config + CLI overrides.

## Edge cases

- Copilot CLI not installed.
- Not authenticated.
- Copilot CLI prompts for trust confirmation.

## Non-functional constraints

- Never print tokens.
- Timeouts for long-running calls.
