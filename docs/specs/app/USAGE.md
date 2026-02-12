# Runtime Usage (CLI + Artifacts)

This document describes the **end-user surface area** of ReviewCat: the CLI
commands, what they do, and what artifacts they write.

> Note: This repository is currently **planning/specs-first**. Some commands
> and flags are described here as the intended interface.

## Commands

### `reviewcat demo`

Runs the review pipeline on a bundled sample diff.

- Produces a full audit directory.
- Requires no GitHub authentication.

### `reviewcat review`

Reviews a local git diff.

Common flags (planned):

- `--base <ref>` / `--head <ref>`: select a diff range.
- `--include <glob>` / `--exclude <glob>`: path filtering.

Default diff range (planned):

- `git diff --merge-base origin/main...HEAD`

### `reviewcat pr`

Reviews a GitHub Pull Request.

- Fetches PR diff via GitHub tooling.
- Generates the same audit artifacts as local review.
- Optional: post a unified review comment.

### `reviewcat fix`

Generates patch suggestions from the current findings/action plan.

- Optional: apply patches (guarded by policy).
- Optional: open a PR.

### `reviewcat watch`

Daemon mode that periodically runs reviews and can dispatch fixes.

- Polls for new commits.
- Runs `review`/`pr` depending on configuration.
- For critical/high findings (policy-controlled), can create issues and dispatch
  coding agents.

## Output artifacts

Runtime audits live under:

- `~/.reviewcat/audits/<audit_id>/`

Minimum artifacts (intended):

- `audit.json` — machine-readable top-level record of the run.
- `unified_review.md` — human-readable unified review.
- `action_plan.json` — issue-ready action items.
- `persona/` — one JSON output per persona.
- `ledger/` — Copilot CLI prompt ledger:
  - `ledger/copilot_prompts.jsonl`
  - `ledger/copilot_raw_outputs/<call_id>.txt`

An index is maintained at:

- `~/.reviewcat/audits/index.json`

See also:

- `components/AuditRecord.md`
- `components/PromptRecord.md`
- `../dev/systems/AuditStoreSystem.md`

## Review pipeline (conceptual)

1. **Collect input** (repo root, diff range, include/exclude filters)
2. **Build context** (diff hunks + optional surrounding context windows)
3. **Persona passes** (structured JSON findings, with schema validation/repair)
4. **Synthesis** (dedupe, prioritize, unified markdown + action plan JSON)
5. **Persist audit** (write artifacts + update index)

GitHub integration (issues/PRs/comments) is optional and must be explicitly
enabled.
