# ReviewInput component

## Overview

`ReviewInput` is the normalized input passed into persona review.

It is derived from a git diff and optional file context.

## Requirements

1. Must include a stable, deterministic list of files.
2. Must include per-file diff hunks.
3. Must include a size summary to support chunking.

## Interfaces

Suggested JSON shape (may be internal-only):

- `base_ref`: string
- `head_ref`: string
- `merge_base`: string (optional)
- `files`: array of:
  - `path`: string
  - `status`: `added|modified|deleted|renamed`
  - `old_path`: string (optional)
  - `diff`: string
  - `context`: string (optional)

## Acceptance criteria

- For a given repo state and base/head, `ReviewInput` is byte-for-byte stable.

## Test cases

- Diff with add/modify/delete.
- Rename includes `old_path`.

## Edge cases

- Binary file diffs: represent as metadata-only entry with a placeholder diff.

## Non-functional constraints

- Avoid embedding entire file contents unless explicitly requested.
