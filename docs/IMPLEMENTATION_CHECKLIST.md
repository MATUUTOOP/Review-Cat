# ReviewCat implementation checklist

This is a practical checklist aligned to the design. It is intentionally explicit and sequential.

## Phase 0: repo bootstrap

- [ ] Choose implementation language (recommendation: Go for single-binary distribution).
- [ ] Create repository layout for the ReviewCat tool.
- [ ] Add a build script (`scripts/build.sh`) and a test script (`scripts/test.sh`).
- [ ] Add a minimal `reviewcat --help` with command stubs.

## Phase 1: artifacts and demo mode

- [ ] Define JSON schema for persona findings and audit record.
- [ ] Implement `docs/audits/<audit_id>/` directory creation.
- [ ] Implement `audit.json` writing (stable, deterministic ordering).
- [ ] Implement `unified_review.md` writing.
- [ ] Implement `action_plan.json` writing.
- [ ] Implement prompt ledger:
  - [ ] `ledger/copilot_prompts.jsonl`
  - [ ] `ledger/copilot_raw_outputs/`
- [ ] Add `reviewcat demo`:
  - [ ] bundled sample diff
  - [ ] deterministic output

## Phase 2: Copilot runner

- [ ] Implement `CopilotRunnerSystem` that can:
  - [ ] call `copilot -p` with a prompt
  - [ ] set model (optional)
  - [ ] set tool allow/deny options (policy)
  - [ ] capture stdout/stderr and exit codes
  - [ ] write prompt ledger entries
- [ ] Add a record/replay mode for tests (stub Copilot output).

## Phase 3: local diff review

- [ ] Implement `RepoDiffSystem`:
  - [ ] changed files list
  - [ ] diff hunks
  - [ ] optional context windows
  - [ ] include/exclude filters
- [ ] Implement persona prompts:
  - [ ] security
  - [ ] performance
  - [ ] architecture
  - [ ] testing
  - [ ] docs
- [ ] Implement JSON schema validation and repair prompts.
- [ ] Implement `SynthesisSystem`:
  - [ ] dedupe
  - [ ] prioritization
  - [ ] unified markdown
  - [ ] action plan JSON
- [ ] Implement `reviewcat review`.

## Phase 4: GitHub PR integration (optional but high impact)

- [ ] Implement `GitHubOpsSystem` via `gh`:
  - [ ] fetch PR diff
  - [ ] post unified comment (opt-in)
  - [ ] attach links to artifacts
- [ ] Implement `reviewcat pr`.

## Phase 5: fix branch automation (optional)

- [ ] Implement patch planning:
  - [ ] small localized changes
  - [ ] tests-first preference
  - [ ] explicit gating flags
- [ ] Implement patch apply with safety checks.
- [ ] Implement `reviewcat fix`.

## Phase 6: DirectorDev self-building

- [ ] Define role agents in `.github/agents/` (director, implementer, QA, docs, security, code-review).
- [ ] Implement `reviewcat dev director`:
  - [ ] reads a target spec
  - [ ] runs plan
  - [ ] delegates sub-tasks to role agents
  - [ ] runs build/test loop
  - [ ] records a development audit under `docs/audits/dev/`

## Phase 7: hackathon submission readiness

- [ ] README includes:
  - [ ] one-command demo
  - [ ] optional GitHub mode instructions
  - [ ] troubleshooting
- [ ] Include example artifacts (or screenshots) in the repo.
- [ ] DEV post includes:
  - [ ] Copilot CLI prompt evidence
  - [ ] how to test
  - [ ] what you built
