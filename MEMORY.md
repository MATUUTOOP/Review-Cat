# ReviewCat — Shared Focus Memory

This file is a **bounded, shared “what matters right now” focus view**.

- It is **tracked** in git.
- It is **maintained by the Director** (or a dedicated memory-maintenance workflow).
- It is **derived** from durable engrams under `memory/st/` and `memory/lt/`.
- The authoritative engram LUT is `memory/catalog.json`.
- It is intentionally **regeneratable**; durable decisions belong in engrams.

## Guardrails (non-negotiable)

- **No secrets**. Do not include tokens, PATs, credentials, or private URLs.
- Keep diffs **small and high-signal**.
- Workers MUST treat this file as **read-only**.

## Current focus

- (docs) Canonicalize docs + specs under `docs/specs/{dev,app}/` (done).
- (bootstrap) Stand up Phase 0 dev harness scaffold and get the build/test gate green.

## Active constraints

- Enforce memory/request budgets from `config/dev.toml`.
- Prefer small PRs; avoid churn across parallel worktrees.

## Recent high-signal (ST)

- Docs re-org: `docs/dev/` and `docs/app/` were migrated into `docs/specs/dev/` and `docs/specs/app/`.
	- All repo links should target `docs/specs/**` (old `docs/dev/**` and `docs/app/**` paths are obsolete).
	- Track entry points:
		- Dev: `docs/specs/dev/INDEX.md`
		- App: `docs/specs/app/INDEX.md`

## Durable conventions (LT pointers)

- (placeholder) Link to the most relevant `memory/lt/<batch_id>/engram_<engram_id>.json` engrams.

## Update policy

- Update at a controlled cadence configured in `config/dev.toml`:
	- `memory.memory_md_update_cadence`
	- `memory.memory_md_update_every_n_heartbeats`
- Keep within `memory.memory_md_max_bytes` / `memory.memory_md_max_items`.

## Last updated

- 2026-02-12
