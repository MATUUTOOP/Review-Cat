# ReviewCat: Copilot CLI-Powered Persona Code Review Workflow

This is the primary design doc for a hackathon entry for the DEV "GitHub Copilot CLI Challenge".

Judging criteria:

- Use of GitHub Copilot CLI
- Usability and User Experience
- Originality and Creativity

This design is optimized to be:

- Judgeable quickly (one command demo, minimal dependencies)
- Explicit about Copilot CLI usage (prompt ledger artifacts)
- Safe by default (dry-run, allowlists)
- Buildable in a hackathon timeframe

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

Hackathon goals:

- Prove Copilot CLI was meaningfully used during development and at runtime.
- Demonstrate Copilot CLI features (programmatic mode, plan mode, permissions guardrails).

## Non-goals

- Fully replacing human review.
- Auto-merging changes by default.
- A GUI-first product.
- A mandatory Windows tray daemon.

A tray app can be a later enhancement, but it increases judge friction and reduces the likelihood of a smooth evaluation.

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

### Invocation modes

- Programmatic mode for deterministic persona runs.
  - `copilot -p "..." ...`
- Plan mode for complex end-to-end tasks (optional).

### Guardrails

- Default is dry-run.
- Prefer minimal allowlists for tools.
- Explicitly deny destructive commands by default.

ReviewCat treats safety as part of UX: users can opt into broader permissions, but the tool should make the risks clear.

### Prompt ledger

Every Copilot CLI interaction is recorded as an append-only log.

This is critical for the hackathon:

- judges can see Copilot CLI usage clearly
- reviewers can reproduce a run
- improvements can be made to prompts empirically

## Self-building development workflow (DirectorDev)

A core differentiator is that ReviewCat is designed to help build itself.

The project includes a DirectorDev workflow that coordinates multiple Copilot CLI agents (roles) to handle typical software project responsibilities.

### Concept

- A Director agent owns:
  - scope control
  - planning
  - task decomposition
  - acceptance criteria
  - integration quality
- Specialized role agents execute sub-tasks:
  - architecture, implementation, QA, docs, security, UX

The Director recursively delegates until a feature is complete.

### How this maps to Copilot CLI features

- Use custom agents (repository-level) for each role.
- Use programmatic mode to run those agents in a repeatable way.
- Use the Task agent pattern to run builds/tests in a controlled loop.

### DirectorDev loop

For each backlog item:

1. Director writes or updates a spec (in `reviewcat_design/specs/`).
2. Director assigns sub-tasks to role agents:
   - Implementation agent: produce code changes.
   - QA agent: add tests and ensure determinism.
   - Docs agent: update README and examples.
   - Security agent: check for dangerous defaults and data leaks.
3. Director runs:
   - build
   - unit tests
   - demo mode
4. Director requests a code review from a Code-review agent.
5. Director iterates until acceptance criteria are met.

Artifacts from DirectorDev are stored under `docs/audits/dev/` to mirror the runtime audit model.

### Deliverables for the hackathon post

DirectorDev should generate a short bundle of evidence:

- a list of Copilot CLI prompts used to build the project
- before/after diffs
- the final demo run

## Implementation plan (do not miss steps)

This is the minimal complete path to a judgeable submission.

### Phase 0: repository and build

- Choose implementation language and packaging.
  - Recommendation: Go or Python for hackathon speed.
  - Requirement: cross-platform, one-command demo.
- Create a reproducible build:
  - `./scripts/build.sh`
  - `./scripts/test.sh`

Acceptance:

- A judge can build and run `reviewcat demo` successfully.

### Phase 1: demo mode

- Bundle a deterministic sample diff.
- Implement audit directory output.
- Implement prompt ledger.

Acceptance:

- `reviewcat demo` writes a complete audit with unified review and action plan.

### Phase 2: local review

- Implement repo diff collection.
- Implement persona loop.
- Implement synthesis.

Acceptance:

- `reviewcat review` works on a real repo diff.

### Phase 3: PR review

- Implement PR diff fetch via `gh`.
- Optionally post unified comment.

Acceptance:

- With `gh auth login` done, `reviewcat pr <url> --comment` posts a unified comment.

### Phase 4: optional fix branch

- Generate safe patches.
- Apply patches behind explicit flags.
- Run tests.
- Open PR.

Acceptance:

- A fix branch can be created without breaking the repo.

### Phase 5: DirectorDev

- Add role agent definitions.
- Add a small script to run the DirectorDev loop on one spec.

Acceptance:

- DirectorDev can complete a small feature end-to-end.

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

## Submission checklist

- Repo contains:
  - clear README with "How to test" steps
  - demo mode
  - sample output screenshots
  - prompt ledger evidence

- DEV post includes:
  - what you built
  - how to run
  - how Copilot CLI was used (include prompt excerpts)
  - testing credentials only if needed (prefer no-auth demo)
