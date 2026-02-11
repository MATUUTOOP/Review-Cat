# ReviewCat — TODO

> Actionable task list mapped to **PLAN.md** phases.
> Each item maps to a spec under `docs/specs/` where applicable.
> Status: `[ ]` = not started, `[-]` = in progress, `[x]` = done

---

## Phase 0: Repository Bootstrap & Dev Harness

- [ ] Create `app/` directory hierarchy (`src/core/`, `src/cli/`, `src/daemon/`, `src/ui/`, `src/copilot/`, `include/`, `tests/`, `config/`, `scripts/`)
- [ ] Create `dev/` directory hierarchy (`agents/`, `harness/`, `plans/`, `prompts/`, `scripts/`, `audits/`)
- [ ] Write root `CMakeLists.txt` (delegates to `app/CMakeLists.txt`)
- [ ] Write `app/CMakeLists.txt` with targets: `reviewcat` binary, `reviewcat_core` library, `reviewcat_tests`
- [ ] Set up vcpkg manifest (`vcpkg.json`) or git submodules for: `nlohmann/json`, `toml++`, `Catch2`, `libgit2`, `imgui`, `SDL2/GLFW`, `spdlog`
- [ ] Write `scripts/build.sh` — CMake configure + build
- [ ] Write `scripts/test.sh` — Run Catch2 test binary
- [ ] Write `scripts/clean.sh` — Remove build artifacts
- [ ] Write `dev/harness/director.sh` — Heartbeat daemon skeleton (see PLAN.md §5.1)
- [ ] Write `dev/harness/run-cycle.sh` — Agent cycle orchestration (see PLAN.md §5.2)
- [ ] Write `dev/harness/record-audit.sh` — Audit recording helper
- [ ] Write `dev/scripts/bootstrap.sh` — One-shot dev environment setup
- [ ] Create `.github/agents/` directory with agent profile stubs
- [ ] Create `dev/agents/` role profiles: `architect.md`, `implementer.md`, `qa.md`, `docs.md`, `security.md`, `code-review.md`
- [ ] Create `dev/plans/prd.json` initial backlog (Phase 0 items)
- [ ] Verify `./scripts/build.sh && ./scripts/test.sh` works (empty project compiles, zero tests pass)
- [ ] Create `.gitignore` (build/, *.o, *.a, *.d, reviewcat.toml user overrides)

## Phase 1: Director Agent (Agent 0)

- [ ] Implement Director heartbeat loop in `dev/harness/director.sh` (PLAN.md §5.1)
  - [ ] Read `dev/plans/prd.json` for task backlog
  - [ ] Pick highest-priority incomplete item
  - [ ] Invoke `dev/harness/run-cycle.sh` for the task
  - [ ] Run `./scripts/build.sh && ./scripts/test.sh` as validation gate
  - [ ] On success: mark item complete in `prd.json`, commit
  - [ ] On failure: increment retry count, log, skip after max retries
  - [ ] Sleep for configurable interval
- [ ] Implement `dev/harness/run-cycle.sh` sub-agent orchestration
  - [ ] Implementer agent: `copilot -p @dev/agents/implementer.md "..."`
  - [ ] QA agent: `copilot -p @dev/agents/qa.md "..."`
  - [ ] Docs agent: `copilot -p @dev/agents/docs.md "..."`
  - [ ] Security review agent: `copilot -p @dev/agents/security.md "..."`
  - [ ] Code review agent: `copilot -p @dev/agents/code-review.md "..."`
  - [ ] Capture all agent output to `dev/audits/<bundle>/ledger/`
- [ ] Implement `dev/harness/record-audit.sh`
  - [ ] Bundle: ledger files + build log + test log + git diff
  - [ ] Write audit index (`dev/audits/index.json`)
- [ ] Write Director-facing prompt templates in `dev/prompts/`
- [ ] Test Director with a trivial spec (e.g., "create a hello world main.cpp")

## Phase 2: Core App Skeleton (C++)

> Specs: `components/RunConfig.md`, `entities/AuditIdFactory.md`, `components/AuditRecord.md`, `components/PromptRecord.md`, `components/ReviewFinding.md`, `components/ReviewInput.md`

- [ ] `app/src/cli/main.cpp` — Entry point, arg parsing (subcommands: `demo`, `review`, `pr`, `fix`, `watch`, `ui`)
- [ ] `app/src/core/run_config.h/.cpp` — `RunConfig` struct: load from TOML, CLI flag overrides (spec: `RunConfig.md`)
- [ ] `app/src/core/audit_id_factory.h/.cpp` — `AuditIdFactory`: epoch-based UUID generation (spec: `AuditIdFactory.md`)
- [ ] `app/src/core/audit_record.h/.cpp` — `AuditRecord` struct: JSON serialization (spec: `AuditRecord.md`)
- [ ] `app/src/core/prompt_record.h/.cpp` — `PromptRecord` struct: prompt ledger (spec: `PromptRecord.md`)
- [ ] `app/src/core/review_finding.h/.cpp` — `ReviewFinding` struct (spec: `ReviewFinding.md`)
- [ ] `app/src/core/review_input.h/.cpp` — `ReviewInput` struct: diff + metadata (spec: `ReviewInput.md`)
- [ ] `app/config/reviewcat.example.toml` — Example config file with all settings documented
- [ ] `app/config/personas/` — Default persona prompt templates (security, performance, architecture, testing, docs)
- [ ] `reviewcat demo` — Bundled sample diff → persona review → markdown output
- [ ] `app/tests/test_run_config.cpp` — Unit tests for RunConfig (Catch2)
- [ ] `app/tests/test_audit_id.cpp` — Unit tests for AuditIdFactory
- [ ] `app/tests/test_review_finding.cpp` — Unit tests for ReviewFinding

## Phase 3: Review Pipeline (C++)

> Specs: `systems/RepoDiffSystem.md`, `systems/CopilotRunnerSystem.md`, `systems/PersonaReviewSystem.md`, `systems/SynthesisSystem.md`, `systems/AuditStoreSystem.md`, `entities/PromptFactory.md`

- [ ] `app/src/core/repo_diff_system.h/.cpp` — RepoDiffSystem (spec: `RepoDiffSystem.md`)
  - [ ] `libgit2` integration for diff extraction
  - [ ] Subprocess fallback (`git diff`)
  - [ ] Diff chunking for prompt budget (`ReviewInput.md` §chunk strategy)
- [ ] `app/src/copilot/copilot_runner.h/.cpp` — CopilotRunnerSystem (spec: `CopilotRunnerSystem.md`)
  - [ ] Subprocess wrapper for `copilot -p "prompt"`
  - [ ] Capture stdout/stderr, exit code
  - [ ] JSON response parsing and validation
  - [ ] Record/replay mode for deterministic testing
  - [ ] Prompt ledger (`PromptRecord`) recording
- [ ] `app/src/core/prompt_factory.h/.cpp` — PromptFactory (spec: `PromptFactory.md`)
  - [ ] Build persona-specific prompts from templates + diff chunks
- [ ] `app/src/core/persona_review_system.h/.cpp` — PersonaReviewSystem (spec: `PersonaReviewSystem.md`)
  - [ ] Iterate enabled personas
  - [ ] Call CopilotRunner for each persona × chunk
  - [ ] Parse findings, validate JSON, repair malformed responses
- [ ] `app/src/core/synthesis_system.h/.cpp` — SynthesisSystem (spec: `SynthesisSystem.md`)
  - [ ] Deduplicate overlapping findings
  - [ ] Prioritize by severity / confidence
  - [ ] Generate unified markdown report
- [ ] `app/src/core/audit_store_system.h/.cpp` — AuditStoreSystem (spec: `AuditStoreSystem.md`)
  - [ ] Write audit bundle to disk (findings + ledger + config snapshot)
  - [ ] Maintain audit index
- [ ] `reviewcat review <path>` — End-to-end: diff → personas → synthesis → audit → stdout
- [ ] Integration tests: record/replay full pipeline with canned Copilot responses
- [ ] Unit tests for each system

## Phase 4: GitHub Integration

> Specs: `systems/GitHubOpsSystem.md`

- [ ] `app/src/core/github_ops_system.h/.cpp` — GitHubOpsSystem (spec: `GitHubOpsSystem.md`)
  - [ ] Fetch PR diff via `gh pr diff`
  - [ ] Post unified review comment via `gh pr comment`
  - [ ] Create issues via `gh issue create`
  - [ ] Handle rate limits, token validation
- [ ] `reviewcat pr <PR#>` — Review a PR end-to-end
- [ ] `reviewcat watch` — Daemon mode: poll for new commits/PRs, auto-review
  - [ ] Configurable poll interval
  - [ ] Persistent PID file
  - [ ] Graceful shutdown on SIGTERM/SIGINT
- [ ] Integration tests with mocked `gh` responses

## Phase 5: Patch Automation

> Specs: `systems/PatchApplySystem.md`

- [ ] `app/src/core/patch_apply_system.h/.cpp` — PatchApplySystem (spec: `PatchApplySystem.md`)
  - [ ] Generate unified diffs from Copilot fix suggestions
  - [ ] Dry-run validation (apply in temp worktree)
  - [ ] Apply with backup
  - [ ] Safety checks (no binary files, max patch size)
- [ ] `reviewcat fix <path>` — Review + auto-apply patches
- [ ] Unit tests for patch generation and application

## Phase 6: End-User UI (C++)

- [ ] Set up Dear ImGui with SDL2 or GLFW backend in `app/src/ui/`
- [ ] Main window layout: sidebar nav + content area
- [ ] Dashboard panel — active review status, recent findings, daemon health
- [ ] Settings panel — load/save `reviewcat.toml`, field editors for all settings
  - [ ] Copilot credentials
  - [ ] GitHub access token
  - [ ] Target repository + base branch
  - [ ] Review interval
  - [ ] Personas enabled/disabled
  - [ ] Auto-comment and auto-fix toggles
  - [ ] Redaction rules
- [ ] Stats panel — review counts, severity breakdown, persona activity, charts
- [ ] Audit Log panel — browse past runs, view findings, open artifacts
- [ ] Controls panel — start/stop daemon, trigger manual review, open audit dir
- [ ] `reviewcat ui` subcommand to launch the window
- [ ] Window persists while daemon runs headless in background thread

## Phase 7: Polish & Distribution

- [ ] Produce single static binary (`reviewcat`) via static linking
- [ ] Comprehensive error messages and `spdlog`-based logging
- [ ] End-user documentation (`docs/USAGE.md`, `docs/CONFIGURATION.md`)
- [ ] Man page or `--help` with detailed subcommand docs
- [ ] CI/CD pipeline (GitHub Actions): CMake build, Catch2 tests, static analysis
- [ ] Release workflow: build matrix (Linux x86_64, ARM64; WSL validated)
- [ ] Update README.md with build instructions, quick start, screenshots

---

## Cross-Cutting Concerns

- [ ] Establish C++ code style (clang-format config)
- [ ] Set up clang-tidy for static analysis
- [ ] Add `compile_commands.json` generation in CMake for IDE support
- [ ] Document WSL prerequisites (Ubuntu packages, Copilot CLI install)
- [ ] Security: never log or store tokens; redact sensitive paths in audits

---

## Notes

- **Dev harness** items (Phase 0–1) are all **bash/shell** — no C++ compilation needed.
- **App** items (Phase 2–7) are all **C++** — require CMake build.
- The Director (Agent 0) can begin implementing Phase 2+ items autonomously once Phase 0–1 are complete.
- Each TODO traces to a spec in `docs/specs/` where applicable.
- Mark items `[x]` as they are completed; items can also be tracked via `dev/plans/prd.json`.
