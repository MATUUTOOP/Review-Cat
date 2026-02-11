# SynthesisSystem

## Overview

`SynthesisSystem` merges persona findings into a unified review and an actionable plan.

## Requirements

1. Must deduplicate similar findings.
2. Must prioritize by severity and confidence.
3. Must produce `unified_review.md` and `action_plan.json`.
4. Must preserve traceability back to personas.

## Interfaces

Inputs:

- list of persona findings

Outputs:

- `unified_review.md`
- `action_plan.json`

## Acceptance criteria

- Unified review includes:
  - summary
  - top findings
  - do-now/do-next ordering
  - explicit unknowns
- Action plan items have:
  - title
  - description
  - priority
  - affected files

## Test cases

- Two identical findings merge.
- Conflicting severities choose higher.
- Output markdown is stable.

## Edge cases

- Large number of findings.
- All personas return empty.

## Non-functional constraints

- Deterministic ordering for snapshot tests.
