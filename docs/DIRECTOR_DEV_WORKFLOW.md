# DirectorDev Workflow (Recursive Development Coordination)

This document specifies how the ReviewCat project "builds itself" using GitHub
Copilot CLI, with a Director daemon (Agent 0) coordinating multiple role agents.

> **See also:** [PLAN.md](../PLAN.md) §5 for heartbeat architecture and
> [TODO.md](../TODO.md) Phase 0–1 for implementation tasks.

The key intent is not full autonomy. The intent is:

- consistent decomposition
- explicit acceptance criteria
- repeatable build/test loops
- recorded evidence of Copilot CLI usage
- autonomous forward progress with human oversight

## Roles

DirectorDev coordinates these roles:

- Director: decomposes work, enforces scope, merges outputs, validates acceptance.
- Architect: reviews architecture changes, watches complexity.
- Implementer: writes code.
- QA: writes tests and adds record/replay fixtures.
- Docs: maintains README, examples, prompt cookbook.
- Security: enforces safe defaults, redaction, permission policy.
- Code-review: reviews diffs and blocks low-signal changes.

In Copilot CLI, these roles are expressed as custom agents:

- Agent profiles live in `.github/agents/` (Copilot CLI repo-level agents).
- Role-specific prompt files live in `dev/agents/` (e.g., `architect.md`,
  `implementer.md`, `qa.md`, `docs.md`, `security.md`, `code-review.md`).
- All agents are invoked via `copilot -p @dev/agents/<role>.md "..."`.

All development tooling is **bash shell scripts** under `dev/`.
No C++ compilation is required for the dev harness to operate.

## Inputs

- A target spec file in `docs/specs/`.
- Current repository state.
- PRD backlog (`dev/plans/prd.json`) with task items and status.
- Optional constraints:
  - time budget
  - risk tolerance (dry-run vs automation)
  - scope lock (files in scope for the target spec)

## Outputs

- Code changes implementing the spec.
- Tests proving acceptance criteria.
- Updated docs.
- A development audit bundle under `dev/audits/<audit_id>/`:
  - `ledger/` — prompt/response pairs per agent
  - `build.log` — build output
  - `test.log` — test output
  - `diff.patch` — before/after diff
  - `summary.md` — Director’s completion note

Audit bundles are indexed in `dev/audits/index.json`.

## Orchestration Algorithm

The Director runs as a **bash heartbeat daemon** (`dev/harness/director.sh`).
See [PLAN.md](../PLAN.md) §5 for the full heartbeat loop pseudocode.

Per-cycle algorithm:

1. Director reads `dev/plans/prd.json` and picks the highest-priority incomplete item.
2. Director loads the target spec from `docs/specs/` and extracts:
   - requirements
   - interfaces
   - acceptance criteria
   - test cases
3. Director creates sub-tasks and assigns them to role agents.
4. Director runs role agents sequentially via `dev/harness/run-cycle.sh`:
   - Implementer: `copilot -p @dev/agents/implementer.md "..."`
   - QA: `copilot -p @dev/agents/qa.md "..."`
   - Docs: `copilot -p @dev/agents/docs.md "..."`
   - Security: `copilot -p @dev/agents/security.md "..."`
   - Code-review: `copilot -p @dev/agents/code-review.md "..."`
   - All output is captured to `dev/audits/<bundle>/ledger/`.
5. Director runs validation:
   - `./scripts/build.sh` (CMake build)
   - `./scripts/test.sh` (Catch2 tests)
6. On success:
   - Mark item complete in `dev/plans/prd.json` (via `jq`).
   - `git add -A && git commit -m "feat(<task>): implement spec"`
7. On failure:
   - Increment retry count. Skip after max retries (default: 3).
8. Record audit bundle to `dev/audits/`.
9. Sleep for configurable interval (default: 60s).

## Guardrails

- **Dry-run is default** — no `git push`, no GitHub mutations.
- **Scope lock** — Director refuses to modify files outside the spec’s scope.
- **Retry budget** — Max 3 retries per sub-task before marking failed.
- **Dangerous command deny list** — `rm -rf /`, `git push --force`, etc.
- **Watchdog timeout** — Kill subprocess if a cycle exceeds time limit.
- **Permission profiles** — Copilot CLI `--allow-tools` / `--deny-tools` flags.
- Director must refuse to:
  - modify files outside repo scope without explicit approval
  - post to GitHub without explicit flags
  - run destructive commands

## Recursive behavior

DirectorDev is recursive in the sense that:

- if a spec requires new subsystems, DirectorDev creates additional specs first
- each new spec becomes a new loop iteration

This keeps work modular and avoids monolithic changes.

## How to Demonstrate

- Run one small DirectorDev cycle:
  ```bash
  ./dev/harness/director.sh  # or run a single cycle manually
  ```
- Show:
  - the spec file (`docs/specs/<spec>.md`)
  - the resulting code change (`git diff`)
  - the test run (`./scripts/test.sh`)
  - the prompt ledger (`dev/audits/<bundle>/ledger/`)

The prompt ledger is the proof that Copilot CLI was used meaningfully,
not just incidentally.
