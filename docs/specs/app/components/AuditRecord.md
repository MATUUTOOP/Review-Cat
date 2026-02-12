# AuditRecord component

## Overview

`AuditRecord` is the top-level persisted record for a ReviewCat run. It is the canonical source of truth for what was reviewed, which prompts ran, what outputs were produced, and where artifacts live.

## Requirements

1. Must uniquely identify a run (`audit_id`).
2. Must record the repo, branch, base/head refs, and commit hashes when available.
3. Must record which personas ran and the exact artifact paths produced.
4. Must be safe to share publicly (no tokens, no secrets, no absolute local paths by default).

## Bundle structure

An audit bundle (e.g., `dev/audits/<audit_id>/`) is expected to follow a predictable layout:

```
dev/audits/<audit_id>/
├── meta.json
├── audit.json
├── worker.json
├── ledger/
│   ├── coder.txt
│   └── qa.txt
├── patches/
│   └── diff.patch
├── build.log
├── test.log
└── summary.md
```

## Interfaces

Stored as `docs/audits/<audit_id>/audit.json`.

Recommended fields:

- `audit_id`: string
- `created_at`: ISO-8601 string
- `mode`: `demo|review|pr|fix|watch|dev`
- `repo`: object
  - `owner_repo`: string (optional)
  - `local_path`: string (optional, default omitted)
- `git`: object
  - `base_ref`, `head_ref`: string
  - `base_commit`, `head_commit`: string (optional)
- `personas`: array of persona names
- `artifacts`: object
  - `unified_review_md`
  - `action_plan_json`
  - `persona_dir`
  - `ledger_dir`
- `github`: object (optional)
  - `pr_url`, `issue_url`, `comment_url`
- `status`: `success|failed|partial`
- `errors`: array of strings (optional)

## Acceptance criteria

- `audit.json` is written on both success and failure.
- If a run fails mid-way, `status=partial` and errors are recorded.
- Artifact paths are relative to repo root.

## Test cases

- Serialize and deserialize `AuditRecord` round-trip.
- Verify deterministic JSON output for the same inputs.
- Verify that secrets and tokens are not present.

## Edge cases

- Detached HEAD.
- No remote named origin.
- PR diff fetched but repo checkout missing.

## Non-functional constraints

- Deterministic output for snapshot tests.
- Backwards compatible changes (additive fields preferred).
