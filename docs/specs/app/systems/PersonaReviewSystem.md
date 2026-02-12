# PersonaReviewSystem

## Overview

`PersonaReviewSystem` runs a configured list of persona prompts and validates the resulting JSON findings.

## Requirements

1. Must load persona definitions (templates) from disk.
2. Must run each persona over all chunks of the review input.
3. Must validate each persona output against the `ReviewFinding` schema.
4. Must repair invalid JSON via a repair prompt (bounded retries).

## Interfaces

Inputs:

- `ReviewInput` (chunked)
- persona list

Outputs:

- `persona/<persona_name>.json`
- aggregated in-memory list of findings

## Acceptance criteria

- If a persona produces invalid JSON, system retries with a repair prompt up to N times.
- If a persona still fails, audit status becomes partial and synthesis continues with remaining personas.

## Test cases

- Valid output passes schema.
- Invalid output triggers repair.
- Repair exhausted marks partial.

## Edge cases

- Persona produces empty list.
- Persona output duplicates across chunks.

## Non-functional constraints

- Deterministic chunk ordering.
- Caching of per-chunk persona calls if enabled.
