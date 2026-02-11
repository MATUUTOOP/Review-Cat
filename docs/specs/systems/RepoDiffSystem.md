# RepoDiffSystem

## Overview

`RepoDiffSystem` collects the review input from a git repository.

It provides:

- changed file list
- diff hunks
- optional context windows

## Requirements

1. Default diff range uses merge-base against a base branch.
2. Must support `--base` and `--head` overrides.
3. Must support include/exclude filtering.
4. Must handle renames and deletions.

## Interfaces

Inputs:

- `base_ref`, `head_ref`
- include/exclude globs

Outputs:

- `ReviewInput` with:
  - changed files
  - per-file diff chunks

## Acceptance criteria

- If diff is empty, system reports "nothing to review" and still writes an audit.
- If base/head invalid, system returns a clear error and suggested remediation.

## Test cases

- Simple diff with one file.
- Rename diff.
- Deleted file.

## Edge cases

- No origin remote.
- Shallow clone.

## Non-functional constraints

- Deterministic ordering of files.
- Avoid reading full files unless needed.
