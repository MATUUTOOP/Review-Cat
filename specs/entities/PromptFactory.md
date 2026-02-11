# PromptFactory entity

## Overview

`PromptFactory` constructs persona prompts from templates, policies, and chunked review input.

## Requirements

1. Templates must be stored in the repo and versioned.
2. Prompts must request strict JSON output.
3. Prompts must embed only the minimum required context.

## Interfaces

- `build_persona_prompt(persona, chunk, schema) -> string`
- `build_repair_prompt(raw_output, error) -> string`
- `build_synthesis_prompt(persona_outputs) -> string`

## Acceptance criteria

- All prompts include the JSON schema contract.
- Repair prompts are bounded in retries.

## Test cases

- Generated prompt contains required fields.
- Prompt size under configured limit.

## Edge cases

- Chunk includes non-UTF8 data.

## Non-functional constraints

- Deterministic template rendering.
