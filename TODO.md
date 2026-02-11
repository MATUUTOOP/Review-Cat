# ReviewCat: TODO

> Actionable task list. Each item maps to a spec or section in `PLAN.md`.
> Status: `[ ]` not started, `[~]` in progress, `[x]` done.

---

## Phase 0: Repository Bootstrap & Dev Harness

- [ ] Create top-level directory structure (`app/`, `dev/`, `.github/agents/`)
- [ ] Initialize TypeScript project (`package.json`, `tsconfig.json`)
- [ ] Install core dependencies (typescript, vitest, tsup, commander, simple-git)
- [ ] Install Copilot CLI SDK (`@github/copilot`)
- [ ] Create `app/scripts/build.sh` and `app/scripts/test.sh`
- [ ] Create `dev/scripts/bootstrap.sh` (dev harness setup)
- [ ] Create `dev/scripts/start-director.sh` (Director daemon launcher)
- [ ] Create `dev/plans/prd.json` (initial product backlog)
- [ ] Create `dev/plans/progress.json` (progress tracking state)
- [ ] Define `.github/agents/director-dev.md` (Agent 0 profile)
- [ ] Define `.github/agents/architect.md` agent profile
- [ ] Define `.github/agents/implementer.md` agent profile
- [ ] Define `.github/agents/qa.md` agent profile
- [ ] Define `.github/agents/docs.md` agent profile
- [ ] Define `.github/agents/security.md` agent profile
- [ ] Define `.github/agents/code-review.md` agent profile
- [ ] Create `.gitignore` with proper exclusions
- [ ] Verify `npm run build` and `npm test` work end-to-end
- [ ] Create `reviewcat.toml` default config template

## Phase 1: Director Agent (Agent 0)

- [ ] Implement `HeartbeatSystem` (persistent loop with configurable interval)
- [ ] Implement `SpecReaderSystem` (parse markdown specs into structured data)
- [ ] Implement `TaskDecomposer` (spec → sub-tasks → role assignments)
- [ ] Implement `AgentExecutor` (invoke Copilot CLI SDK with agent profile)
- [ ] Implement `CheckpointSystem` (inter-agent validation gates)
- [ ] Implement `BuildTestRunner` (run `npm run build` + `npm test` programmatically)
- [ ] Implement `ProgressTracker` (read/write `dev/plans/progress.json`)
- [ ] Implement `DevAuditRecorder` (write dev audit bundles to `dev/audits/`)
- [ ] Implement Director watchdog (timeout, crash recovery, auto-restart)
- [ ] Implement structured commit automation (`git add` + `git commit`)
- [ ] Add Director CLI entry point: `npm run director` or `./dev/scripts/start-director.sh`
- [ ] Test Director heartbeat in isolation (mock agent responses)
- [ ] Test Director full cycle with replay fixtures

## Phase 2: Core App Skeleton

- [ ] Implement CLI frontend with Commander.js (command stubs for all subcommands)
- [ ] Implement `RunConfig` component (TOML parsing + CLI flag overrides)
- [ ] Implement `AuditIdFactory` entity (timestamp + commit hash)
- [ ] Implement `AuditRecord` component (JSON serialization/deserialization)
- [ ] Implement `AuditStoreSystem` (directory creation, artifact writing, index update)
- [ ] Implement `PromptRecord` component (ledger entry structure)
- [ ] Implement `PromptFactory` entity (template rendering, schema injection)
- [ ] Implement `ReviewFinding` component (JSON schema + validation)
- [ ] Implement `ReviewInput` component (diff representation)
- [ ] Bundle sample diff for demo mode
- [ ] Implement `reviewcat demo` command (deterministic output)
- [ ] Write unit tests for all Phase 2 components
- [ ] Write snapshot tests for demo output

## Phase 3: Review Pipeline

- [ ] Implement `RepoDiffSystem` (git diff collection via simple-git)
- [ ] Implement diff chunking (split large diffs to fit prompt budgets)
- [ ] Implement include/exclude glob filtering
- [ ] Implement `CopilotRunnerSystem` (Copilot CLI SDK invocation wrapper)
- [ ] Implement record/replay mode for `CopilotRunnerSystem`
- [ ] Implement prompt ledger writing (append-only JSONL)
- [ ] Implement raw output capture (`ledger/copilot_raw_outputs/`)
- [ ] Implement `PersonaReviewSystem` (persona loop over chunks)
- [ ] Implement JSON schema validation for persona outputs
- [ ] Implement repair prompt flow (bounded retries on invalid JSON)
- [ ] Create persona prompt templates (security, performance, architecture, testing, docs)
- [ ] Implement `SynthesisSystem` (deduplicate findings)
- [ ] Implement finding prioritization (severity × confidence)
- [ ] Implement unified markdown review generation
- [ ] Implement action plan JSON generation
- [ ] Implement `DirectorRuntimeSystem` (end-to-end pipeline orchestration)
- [ ] Implement `reviewcat review` command
- [ ] Write integration tests with replay fixtures
- [ ] Write golden-file snapshot tests

## Phase 4: GitHub Integration

- [ ] Implement `GitHubOpsSystem.fetchPrDiff()` via `gh` CLI
- [ ] Implement `GitHubOpsSystem.postPrComment()` with opt-in gate
- [ ] Implement `GitHubOpsSystem.createIssue()` for action plan items
- [ ] Implement graceful fallback when `gh` is missing/unauthenticated
- [ ] Implement `reviewcat pr` command
- [ ] Implement `reviewcat watch` daemon mode (poll for new commits)
- [ ] Implement watch mode with configurable interval
- [ ] Write integration tests with stubbed `gh` calls

## Phase 5: Patch Automation

- [ ] Implement `PatchApplySystem.planPatches()` (findings → patch plan)
- [ ] Implement `PatchApplySystem.applyPatches()` with safety checks
- [ ] Implement scope validation (only modify files present in diff)
- [ ] Implement rollback on failed patch apply
- [ ] Implement fix branch creation (`git checkout -b`)
- [ ] Implement test-after-fix validation
- [ ] Implement `reviewcat fix` command
- [ ] Write tests for patch application edge cases (CRLF, conflicts)

## Phase 6: End-User UI

- [ ] Set up Electron project in `app/ui/`
- [ ] Implement IPC bridge between Electron renderer and daemon process
- [ ] Implement dashboard view (daemon status, active review, recent findings)
- [ ] Implement settings screen:
  - [ ] Copilot credentials input
  - [ ] GitHub access token input
  - [ ] Target repository selector (`OWNER/REPO`)
  - [ ] Base branch configuration
  - [ ] Review interval slider
  - [ ] Persona enable/disable toggles
  - [ ] Auto-comment toggle
  - [ ] Auto-fix toggle
  - [ ] Redaction rules editor
- [ ] Implement stats view (review counts, finding trends, severity breakdown)
- [ ] Implement agent persona management panel
- [ ] Implement audit log browser (list runs, view artifacts)
- [ ] Implement daemon controls (start/stop, manual review trigger)
- [ ] Implement system tray integration (minimize to tray, notifications)
- [ ] Write UI component tests

## Phase 7: Polish & Distribution

- [ ] Add comprehensive error handling and user-friendly error messages
- [ ] Add structured logging (Winston or Pino)
- [ ] Add onboarding wizard for first-time setup
- [ ] Write end-user documentation (README, Getting Started, FAQ)
- [ ] Write developer documentation (contributing, architecture)
- [ ] Create demo recording script
- [ ] Generate sample output artifacts for repo
- [ ] Package as npm installable (`npm install -g reviewcat`)
- [ ] Package Electron app for distribution (Windows/Linux/macOS)
- [ ] Set up CI/CD pipeline (GitHub Actions)
- [ ] Create release automation

---

## Docs & Specs Maintenance

- [ ] Keep all specs in `docs/specs/` updated as implementation proceeds
- [ ] Add missing specs: `PersonaDefinition`, `UnifiedReview`, `UnifiedFinding`,
      `ActionItem`, `PatchPlanFactory`, `WatchSystem`, `HeartbeatSystem`,
      `UISystem`, `SettingsSystem`
- [ ] Update `IMPLEMENTATION_CHECKLIST.md` to align with this TODO
- [ ] Update `COPILOT_CLI_CHALLENGE_DESIGN.md` to reflect new architecture
- [ ] Update `DIRECTOR_DEV_WORKFLOW.md` to reflect heartbeat model
- [ ] Update `PROMPT_COOKBOOK.md` with new prompt templates

---

## Design Gaps Identified (to be resolved)

- [x] **No app/dev separation** — Resolved: `app/` and `dev/` top-level split (see `PLAN.md`)
- [x] **No UI spec** — Resolved: UI section added to `PLAN.md`; UI spec needed in `docs/specs/`
- [x] **No heartbeat/daemon spec** — Resolved: Heartbeat system designed in `PLAN.md`
- [x] **No Copilot CLI SDK integration** — Resolved: SDK embedded in both app and dev
- [x] **Stale hackathon framing** — Resolved: docs updated to reflect product vision
- [x] **Stale path references** — `reviewcat_design/specs/` → `docs/specs/`
- [x] **Language choice unresolved** — Resolved: TypeScript (see `PLAN.md` §3)
- [x] **Missing component specs** — Identified; listed above for creation
- [x] **No credential management spec** — Resolved: settings screen spec needed
- [x] **No PatchPlanFactory spec** — Identified; needs creation
