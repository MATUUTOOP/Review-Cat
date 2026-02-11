# ReviewCat: Autonomous AI-Powered Code Review Daemon

This is the primary design doc for ReviewCat — an autonomous code review daemon
powered by GitHub Copilot CLI.

> **See also:** [PLAN.md](../PLAN.md) for the comprehensive project plan and
> [TODO.md](../TODO.md) for the actionable task list.

Design principles:

- **Autonomous development** — ReviewCat builds itself using Copilot CLI agents
  orchestrated by a Director daemon (Agent 0).
- **Copilot CLI subprocess** — Copilot CLI is invoked via subprocess calls
  from both bash scripts (dev harness) and C++ (runtime app).
- **Safe by default** — Dry-run, allowlists, explicit opt-in for mutations.
- **Two-part architecture** — `app/` (the product) and `dev/` (the meta-tooling).
- **WSL-native** — Developed and tested on WSL/Linux with Copilot CLI.

## Problem statement

Developers want fast, repeatable, high-signal code review feedback before pushing a PR. Today, Copilot CLI can help review code, but the workflow is ad-hoc: prompt quality varies, outputs are inconsistent, and review artifacts are not stored or comparable over time.

ReviewCat turns Copilot CLI into an opinionated, repeatable code-review workflow that produces:

- structured persona findings
- a single unified review
- an actionable change plan
- optional patches
- an auditable record of how Copilot CLI was used

## Goals

Product goals:

- Provide a high-quality, repeatable review experience on:
  - local diffs
  - GitHub pull requests
- Create artifacts that are:
  - readable (markdown)
  - machine-parseable (JSON)
  - diffable and archivable
- Make it extremely easy for judges to test:
  - a no-auth demo mode
  - optional GitHub mode (gh-based) with clear instructions

Development goals:

- Use Copilot CLI meaningfully during development and at runtime.
- Demonstrate Copilot CLI features (programmatic mode, plan mode, permissions guardrails).

## Non-goals

- Fully replacing human review.
- Auto-merging changes by default.
- Requiring external cloud services (everything runs locally).
- Shipping without a UI (a lightweight native window is part of the product).

The UI is a lightweight **Dear ImGui** window (SDL2/GLFW backend) providing
settings, stats, and command-and-control — not a full GUI-first product.

## Target users

- Solo developers who want a fast pre-PR review.
- Maintainers who want structured triage on incoming PRs.
- Teams that want consistent, persona-based feedback and an artifact trail.

## User experience

### Command surface

ReviewCat is a terminal-first CLI.

- `reviewcat demo`
  - Runs on a bundled sample diff.
  - Produces a full audit directory.
  - Requires no GitHub authentication.

- `reviewcat review [--base <ref>] [--head <ref>] [--include <glob>] [--exclude <glob>]`
  - Reviews a local git diff.
  - Writes artifacts under `docs/audits/<audit_id>/`.

- `reviewcat pr <pr_url|number> [--repo OWNER/REPO] [--comment]`
  - Fetches PR diff via `gh`.
  - Generates artifacts.
  - Optionally posts a unified comment.

- `reviewcat fix [--apply] [--branch <name>] [--pr] [--run-tests]`
  - Generates patch suggestions.
  - Optionally applies them.
  - Optionally opens a PR.

- `reviewcat watch [--branch <name>] [--interval <seconds>]`
  - Polls and runs `review` on new commits.

- `reviewcat dev director`
  - Runs the DirectorDev workflow that coordinates Copilot CLI agents to build and improve the ReviewCat codebase itself.
  - This is the "self-building" mode.
  - The Director runs as a persistent daemon with a heartbeat loop.
  - See `PLAN.md §5` for heartbeat architecture.

### Output and artifacts

Each run creates a directory:

`docs/audits/<audit_id>/`

Minimum artifacts:

- `audit.json` (machine-readable record)
- `unified_review.md` (human-readable)
- `action_plan.json` (issue-ready tasks)
- `persona/` (one JSON per persona)
- `ledger/copilot_prompts.jsonl` (exact Copilot CLI calls)
- `ledger/copilot_raw_outputs/` (raw text output per call)

Judge-friendly behavior:

- Print a one-screen summary at the end:
  - top 5 findings
  - next command suggestions
  - where artifacts were written

## Core review workflow

1. Collect input
   - Determine repo root.
   - Determine diff range:
     - default: `git diff --merge-base origin/main...HEAD`
     - configurable `--base` and `--head`.
   - Apply include/exclude filters.

2. Build review context
   - For each changed file:
     - include diff hunks
     - optionally include small surrounding context windows
   - Chunk content to stay under prompt budgets.

3. Persona passes
   - Run a set of persona prompts via Copilot CLI programmatic mode.
   - Validate responses against a strict JSON schema.
   - If validation fails, re-prompt with a repair prompt.

4. Synthesis
   - Deduplicate findings.
   - Prioritize.
   - Produce unified markdown review.
   - Produce action plan JSON.

5. Optional automation
   - If enabled:
     - create issue
     - create fix branch
     - apply patches
     - open PR

6. Persist audit
   - Write `audit.json`.
   - Update `docs/audits/index.json`.

## Architecture (components, entities, systems)

The repository is split into two top-level sections:

- **`app/`** — The ReviewCat product (CLI, daemon, UI, runtime agents).
- **`dev/`** — The development harness (Director daemon, role agents, build automation).

To match an ECS-style separation and keep modules testable:

- Components are pure data structures.
- Entities are factories that construct validated instances of components.
- Systems contain all logic and side-effects.

### Components (pure data)

Representative components:

- `RunConfig`
- `ReviewInput`
- `PersonaDefinition`
- `PersonaFinding`
- `UnifiedFinding`
- `UnifiedReview`
- `ActionItem`
- `AuditRecord`
- `PromptRecord`

### Entities (factories)

Representative entities:

- `AuditIdFactory` (timestamp + commit hash)
- `PromptFactory` (persona template + chunk injection)
- `PatchPlanFactory` (suggested diffs gated by policy)

### Systems (logic)

Representative systems:

- `RepoDiffSystem` (collect diffs, file lists, context)
- `CopilotRunnerSystem` (invoke Copilot CLI with guardrails)
- `PersonaReviewSystem` (persona loop and JSON validation)
- `SynthesisSystem` (dedupe, prioritize, unify)
- `PatchApplySystem` (optional, safe patch application)
- `GitHubOpsSystem` (gh-based issue/PR/comment operations)
- `AuditStoreSystem` (write artifacts, update index, archive)
- `DirectorRuntimeSystem` (orchestrate end-to-end review flow)

## Copilot CLI integration

ReviewCat uses Copilot CLI as the analysis and generation engine.

### Invocation mode

- **CLI subprocess mode** — Invoke `copilot -p "..."` as a subprocess.
  - From **bash scripts** (dev harness): direct `copilot -p` calls.
  - From **C++ binary** (runtime app): `popen`/`fork+exec` subprocess wrapper.
- Plan mode for complex end-to-end tasks (optional).
- No SDK or npm dependency — Copilot CLI is the only external requirement.

### Guardrails

- Default is dry-run.
- Prefer minimal allowlists for tools.
- Explicitly deny destructive commands by default.

ReviewCat treats safety as part of UX: users can opt into broader permissions, but the tool should make the risks clear.

### Prompt ledger

Every Copilot CLI interaction is recorded as an append-only log.

This is critical for auditability:

- reviewers can see Copilot CLI usage clearly
- runs can be reproduced deterministically
- improvements can be made to prompts empirically

## Self-building development workflow (DirectorDev)

A core differentiator is that ReviewCat is designed to help build itself.

The project includes a DirectorDev workflow that coordinates multiple Copilot
CLI agents (roles) to handle typical software project responsibilities.
All development tooling lives under `dev/`.

### Concept

- **Agent 0 (Director)** runs as a persistent daemon with a heartbeat loop
  (see `PLAN.md §5`).
- The Director owns:
  - scope control
  - planning and task decomposition
  - acceptance criteria
  - integration quality
  - progress tracking
- Specialized role agents execute sub-tasks:
  - architect, implementer, QA, docs, security, code-review

The Director recursively delegates until a feature is complete.

### How this maps to Copilot CLI features

- Custom agents are defined in `.github/agents/` (repository-level).
- Copilot CLI is invoked via subprocess (`copilot -p`) from bash scripts.
- The heartbeat daemon runs agents in a repeatable, auditable loop.
- Record/replay mode enables deterministic testing without live Copilot calls.

### DirectorDev heartbeat loop

The Director daemon runs continuously with a configurable interval:

1. **Wake** — Heartbeat timer fires.
2. **Check backlog** — Read `dev/plans/prd.json` and `dev/plans/progress.json`.
3. **Pick task** — Select highest-priority incomplete item.
4. **Load spec** — Read target spec from `docs/specs/`.
5. **Decompose** — Create sub-tasks, assign to role agents.
6. **Execute** — Run agents sequentially with checkpoints:
   - Implementer: produce code changes.
   - QA: add tests and ensure determinism.
   - Docs: update README and examples.
   - Security: check for dangerous defaults and data leaks.
7. **Validate** — Run build + unit tests.
8. **Review** — Code-review agent validates changes.
9. **Record** — Write development audit bundle to `dev/audits/`.
10. **Commit** — Structured commit with audit trail.
11. **Sleep** — Wait for next heartbeat interval.

### Development audit artifacts

DirectorDev generates auditable evidence for every cycle:

- Prompt ledger (every Copilot CLI subprocess call logged)
- Before/after diffs
- Build/test output logs
- Agent output transcripts

Artifacts are stored under `dev/audits/<audit_id>/`.

## Implementation plan

> **Canonical plan:** See [PLAN.md](../PLAN.md) §9 for the phased plan
> and [TODO.md](../TODO.md) for the full task list.

The implementation language is **C++17/20**. The dev harness is **bash shell
scripts**. Copilot CLI is invoked as a subprocess — no SDK or npm dependency.

### Phase 0: Repository bootstrap and dev harness

- Create `app/` and `dev/` directory structure.
- Set up CMake build system for C++ project.
- Write build/test/clean shell scripts.
- Create Agent 0 heartbeat daemon skeleton (`dev/harness/director.sh`).
- Define agent profiles in `.github/agents/` and `dev/agents/`.

### Phase 1: Director agent (Agent 0)

- Implement heartbeat loop with configurable interval.
- Implement spec reader, task decomposition, agent execution.
- Implement build/test validation, progress tracking, audit recording.

### Phase 2: Core app skeleton

- CLI frontend with command stubs.
- Config, audit, prompt ledger components.
- `reviewcat demo` with bundled sample diff.

### Phase 3: Review pipeline

- RepoDiffSystem, CopilotRunnerSystem, PersonaReviewSystem, SynthesisSystem.
- `reviewcat review` end-to-end.

### Phase 4: GitHub integration

- GitHubOpsSystem, `reviewcat pr`, watch mode daemon.

### Phase 5: Patch automation

- PatchApplySystem, `reviewcat fix`.

### Phase 6: End-user UI

- Dear ImGui window (SDL2/GLFW): dashboard, settings, stats, audit log, daemon controls.

### Phase 7: Polish and distribution

- Single static binary, error handling, spdlog logging, documentation.

## Testing strategy

- Unit tests:
  - schema validation
  - chunking
  - synthesis dedupe
  - audit serialization

- Integration tests:
  - record/replay mode that stubs Copilot CLI responses
  - demo snapshot tests (golden files)

This ensures the project remains testable even if Copilot CLI is unavailable.

## Security and privacy

- Do not read or upload secrets.
- Redact sensitive file globs.
- Avoid default network actions.
- Require explicit opt-in for:
  - posting comments
  - creating issues
  - opening PRs

## Risks and mitigations

- Prompt budget limits
  - chunking and summarization
- Copilot CLI request quotas
  - caching per chunk/persona
  - record/replay tests
- Judge environment variability
  - no-auth demo mode
  - minimal dependencies

## Distribution checklist

- Repo contains:
  - Clear README with quick start and installation steps
  - Demo mode (`reviewcat demo`)
  - Sample output artifacts
  - Prompt ledger evidence of autonomous development
  - Comprehensive specs in `docs/specs/`

- Package includes:
  - Single static binary (`reviewcat`) — no runtime dependencies
  - Dear ImGui UI built into the binary (`reviewcat ui`)
  - Default config template (`reviewcat.toml`)
