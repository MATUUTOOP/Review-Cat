# DirectorRuntimeSystem

## Overview

`DirectorRuntimeSystem` orchestrates the end-to-end review flow (input -> personas -> synthesis -> persistence -> optional GitHub operations).

It is the runtime director (distinct from DirectorDev).

## Requirements

1. Must run the full pipeline in a fixed order.
2. Must support dry-run default.
3. Must surface clear terminal UX.
4. Must always write an audit record even if partial.

## Interfaces

- `run_demo()`
- `run_review(config)`
- `run_pr(config)`
- `run_fix(config)`

## Acceptance criteria

- A failure in any system produces a partial audit rather than losing artifacts.
- Terminal summary includes next steps.

## Test cases

- Pipeline success path in replay mode.
- Persona failure path yields partial status.

## Edge cases

- Repo without origin remote.
- Empty diff.

## Non-functional constraints

- Deterministic ordering and output for judgeability.
