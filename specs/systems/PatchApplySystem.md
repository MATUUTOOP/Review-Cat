# PatchApplySystem

## Overview

`PatchApplySystem` is responsible for applying suggested patches safely.

This is optional functionality and must be gated by explicit flags.

## Requirements

1. Default behavior is to generate patches only (no apply).
2. Applying patches must require an explicit flag.
3. Patch application must be validated:
   - patch cleanly applies
   - no files outside allowed scope are touched
4. Must support rollback if apply fails mid-way.

## Interfaces

- `plan_patches(findings) -> PatchPlan`
- `apply_patches(patch_plan) -> ApplyResult`

## Acceptance criteria

- Without `--apply`, no working tree changes are made.
- With `--apply`, changes are limited to files present in the diff unless explicitly overridden.

## Test cases

- Apply a small patch.
- Reject patch that modifies excluded paths.
- Rollback on failure.

## Edge cases

- Conflicting patches.
- CRLF vs LF.

## Non-functional constraints

- Never run formatters automatically unless explicitly enabled.
- Avoid broad refactors.
