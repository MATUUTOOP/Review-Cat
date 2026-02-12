# ReviewCat Agent System (AGENT.md)

This repository is a **self-improving autonomous development system**:

> review → report → discuss → work → patch → review → merge → repeat

The key idea is that **GitHub Issues/PRs are the durable coordination layer**, while a lightweight **agent bus** provides real-time worker state, error reporting, and memory synchronization.

## Status (what exists today vs target)

This document is an **operating contract** for the target swarm system.

- Today, the repo is largely **planning/specs-first** (docs + `config/dev.toml`).
- The Director/worker implementation (scripts, agents, container lifecycle) is
	being bootstrapped in Phase 0.

Tracking issue: **#16 — _Bootstrap Repo Scaffold + Green Build/Test Gate_**.

## High-level workflow (project loop)

ReviewCat evolves as an alternating loop between the dev harness and the runtime app:

> **bootstrap → dev → app → dev → app → …**

- **bootstrap**: establish toolchain + MCP + labels + initial tasks
- **dev**: Director + workers self-improve the repo (issues → PRs → merges)
- **app**: the runtime product grows (CLI/daemon/UI), then feeds requirements back into dev

## Core execution model (directive)

For the MVP dev harness:

- **Docker-first** execution.
- **One shared Docker image tag** for Director + all workers.
- **One worker container per task** (containers, not images).
- **One git worktree per worker**, bind-mounted into the worker container at `/workspace`.
- Prefer **scale-to-zero**: stop/remove idle worker containers.

This keeps toolchains reproducible while preventing concurrent workers from fighting over the same checkout.

## Autonomy model (human interaction)

Default behavior is **zero-touch autonomous**: the Director runs indefinitely
and advances the loop without waiting for humans.

Humans can still interact in three ways:

1. **Steering (optional):** create/issues, comments, and labels to guide priority.
2. **Blocked escalation:** when an agent cannot proceed safely/clearly, it applies
	`agent-blocked` and posts a structured context comment.
3. **Stop/pause (operational):** stop the Director (or Director container) to halt work.

See Issue #4 for the documentation alignment work around “fully autonomous by default”.

## Who’s who

### Director (Agent 0)

The Director is the orchestrator. It is the only agent allowed to:

- choose/claim issues
- spawn/stop worker containers
- create/merge PRs (depending on guardrail mode)
- publish the authoritative swarm/memory state

In addition, the Director is responsible for **release-cycle orchestration**:

- scheduling a release (batch of issues) and maintaining a release plan
- ensuring worker PRs land in the active **release branch** (`feature/release-*`)
- invoking a dedicated **merge agent** to merge the release PR into `main`
- verifying build/test gates + release tag, then broadcasting the new version

### Workers

Workers do one thing: **execute exactly one assigned task** in their own worktree.

A worker should never self-claim issues. It reports progress and errors to the Director, and produces artifacts (audit bundle, PR branch).

Workers must also stay reasonably up to date with `main` while they work:

- before final validation/PR readiness, a worker should **fetch** and
	**merge/rebase** the latest `main` into its PR branch (Director policy),
	to pull in any new specs, protocol changes, and committed memory engrams.

To prevent drift, workers SHOULD include the following fields in their
heartbeats (see `docs/specs/dev/systems/AgentBusSystem.md`):

- `main_ancestor_sha` (merge-base of worker branch and `main`)
- `catalog_hash_seen` (hash of `memory/catalog.json`)

The Director enforces thresholds from `config/dev.toml` `[policy.sync_main]` by
sending `sync_required` and, for hard incompatibilities, `protocol_incompatibility`.

### Role agents (within a worker)

Within a worker’s task cycle, the worker invokes role agents (Implementer/Coder, QA, Docs, Security, Code-Review) via Copilot CLI prompts.

## Control plane: GitHub + Agent Bus

### GitHub (durable coordination)

GitHub is the source of truth for:

- backlog (Issues)
- implementations (PRs)
- approvals/reviews (PR reviews/comments)
- machine routing (labels: `agent-task`, `agent-claimed`, `agent-review`, `agent-blocked`, priority/persona labels)

### Agent Bus (real-time coordination)

The agent bus is a lightweight socket/pub-sub channel (MVP: Director broker, hub-and-spoke). It is used for:

- worker heartbeats (liveness + stage)
- structured error reports
- swarm/project state snapshots (for UI)
- memory snapshot distribution and memory patch proposals

All timings and networking settings are configured in `config/dev.toml`.

## Local cached state: `STATE.json` (gitignored)

Each repo checkout (including worker worktrees) may contain a root-level
`STATE.json` file used as **local cached state** for the agent process.

- `STATE.json` is **NOT committed** (must be gitignored).
- It is **created lazily** by the daemon/Director/worker if missing.
- It is used to detect **first-run vs resume** after container restart.
- It may cache:
	- last director heartbeat time
	- current release id/branch/PR
	- last-seen `main` HEAD SHA and/or memory catalog hash
	- worker attempt counters / last-known stage

`STATE.json` is an optimization and resilience mechanism only. Durable
coordination remains GitHub Issues/PRs + tracked `/memory/**` engrams.

### Recommended minimum fields

To keep restart/resume behavior predictable across the swarm, `STATE.json`
SHOULD include (at minimum):

- `schema_version`
- `created_at`, `updated_at`
- `active_release` (when applicable): `{release_id, release_branch, release_pr_number}`
- `last_seen`: `{main_sha, catalog_hash, image_tag}`
- `director` (in the main worktree): `{run_id, last_heartbeat_at}`
- `worker` (in worker worktrees): `{worker_id, issue_number, branch_name, stage, attempt}`

Normative guidance and an example JSON are defined in:

- `docs/specs/dev/components/StateFile.md`

## Release model (dev harness)

For the MVP dev harness, work is executed in **release cycles**.

### Release branch + release PR

- The Director opens/maintains a release branch named:
	- `feature/release-<release_id>`
- The Director opens/maintains a single release PR:
	- `feature/release-<release_id>` → `main`

### Worker PR targeting

- Worker PRs should normally target the **release branch**, not `main`.
- Worker PRs should use `Refs #<issue>` rather than `Closes #<issue>`.
- The release PR is responsible for closing issues (aggregated `Closes #...`).

### Merge agent (release finalization)

When a release is ready (all planned issues merged into the release branch),
the Director invokes a dedicated **merge agent expert** to:

1. merge the release PR into `main`
2. resolve merge conflicts (if any) using the release context + recent memory
3. re-run the validation gate as required
4. create/verify the release tag
5. notify the Director of success/failure

### Upgrade protocol (workers + new releases)

When a new version is published:

- The Director broadcasts `release_published` on the agent bus
	(includes tag + `main` SHA + updated container image tag).
- Workers may restart into the new container image **only at safe points**:
	- between commits
	- not mid-rebase/merge
	- clean working tree (preferred)
- If a worker is mid-edit and safe to discard, it may:
	- `git reset --hard HEAD` (and `git clean -fd` if needed)
	- restart and `git fetch`/`git merge` the last pushed commits for its branch
- If a worker is in a critical git operation (commit/rebase/merge), it finishes
	that operation first, then restarts at the next safe point.

This keeps upgrades from corrupting in-flight work while allowing the swarm to
converge on the latest harness/protocol changes.

### Skills library

A repository-level **skills library** documents reusable automation skills and their contract. See `docs/specs/components/SkillsLibrary.md` for SKILL.md conventions and an initial catalog of recommended skills (build, test-runner, memory-query, worktree-manager, docgen).

### Determinism & Reproducibility

- Image must pin tool versions where possible:
  - Copilot CLI
  - gh
  - jq
  - cmake/g++
  - github-mcp-server

## Standard state reporting (DTOs)

Workers communicate using stable JSON DTOs (schemas specified in planning issues/specs). At minimum:

- `protocol_hello` — identity, capabilities, and repo/worktree metadata
- `heartbeat` — progress stage + timestamps (used for TTL detection)
- `worker_error` — structured error DTO (used for retry vs escalate)
- `project_state_snapshot` — Director-emitted snapshot for the UI

Error classification, retry/backoff guidance, and the canonical error DTO fields
are documented in:

- `docs/dev/ERROR_HANDLING.md`

Normative envelope framing and DTO field requirements live in:

- `docs/specs/dev/systems/AgentBusSystem.md`

The Director maintains `SwarmState` (active workers + queue + health) and can periodically emit a `ProjectState` snapshot for the UI.

## Local cached state: `STATE.json` (gitignored)

Each repo checkout (including worker worktrees) may contain a root-level
`STATE.json` file used as **local cached state** for the agent process.

- `STATE.json` is **NOT committed** (must be gitignored).
- It is **created lazily** by the daemon/Director/worker if missing.
- It is used to detect **first-run vs resume** after container restart.
- It may cache:
	- last director heartbeat time
	- current release id/branch/PR
	- last-seen `main` HEAD SHA and/or memory catalog hash
	- worker attempt counters / last-known stage

`STATE.json` is an optimization and resilience mechanism only. Durable
coordination remains GitHub Issues/PRs + tracked `/memory/**` engrams.

(remaining content unchanged)