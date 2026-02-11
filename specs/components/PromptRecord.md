# PromptRecord component

## Overview

`PromptRecord` is the canonical record for one Copilot CLI interaction.

It is written to the prompt ledger and is intended to be sufficient to reproduce the call.

## Requirements

1. Must record prompt text (or a content hash if prompt is too large).
2. Must record the Copilot CLI invocation options (model, allow/deny tools).
3. Must record timestamps and duration.
4. Must record output artifact path.

## Interfaces

Stored as JSON Lines in:

- `docs/audits/<audit_id>/ledger/copilot_prompts.jsonl`

Fields:

- `call_id`: string
- `created_at`: ISO-8601
- `mode`: `programmatic|interactive|plan`
- `agent`: string (optional)
- `model`: string (optional)
- `allow_tools`: array of strings
- `deny_tools`: array of strings
- `prompt_text`: string (or empty if using hash)
- `prompt_sha256`: string (optional)
- `raw_output_path`: string
- `exit_code`: integer
- `duration_ms`: integer

## Acceptance criteria

- Ledger is append-only.
- Each call produces one prompt record.

## Test cases

- Record serialization is stable.
- Large prompt uses hash mode.

## Edge cases

- Copilot CLI fails before producing output.

## Non-functional constraints

- Do not store tokens.
- Prefer relative paths.
