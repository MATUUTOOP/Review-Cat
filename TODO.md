# ReviewCat — TODO

> Actionable task list mapped to **PLAN.md** phases.
> Each item maps to a spec under `docs/specs/` where applicable.
> Status: `[ ]` = not started, `[-]` = in progress, `[x]` = done
>
> **GitHub Issues** are the primary tracking mechanism for autonomous agents.
> This file provides the human-readable overview; `dev/plans/prd.json` and
> GitHub Issues labeled `agent-task` are the machine-readable sources.

---

## Phase 0: Bootstrap & Dev Harness (PRIORITY — Get Director Running)

### Directory Structure
- [ ] Create `app/` hierarchy: `src/core/`, `src/cli/`, `src/daemon/`, `src/ui/`, `src/copilot/`, `include/`, `tests/`, `config/`, `scripts/`
- [ ] Create `dev/` hierarchy: `agents/`, `harness/`, `plans/`, `prompts/`, `scripts/`, `audits/`
- [ ] Create `.github/agents/` for Copilot CLI repo-level agent profiles

### Build System
- [ ] Write root `CMakeLists.txt` (delegates to `app/CMakeLists.txt`)
- [ ] Write `app/CMakeLists.txt` with targets: `reviewcat` binary, `reviewcat_core` lib, `reviewcat_tests`
- [ ] Set up vcpkg manifest (`vcpkg.json`) or git submodules for deps
- [ ] Write `scripts/build.sh` — CMake configure + build
- [ ] Write `scripts/test.sh` — Run Catch2 test binary
- [ ] Write `scripts/clean.sh` — Remove build artifacts
- [ ] Create `.gitignore` (build/, *.o, *.a, worktree dirs, etc.)

### Dev Harness Scripts
- [ ] Write `dev/scripts/bootstrap.sh`:
  - [ ] Verify prerequisites (copilot, gh, jq, cmake, g++)
  - [ ] Configure GitHub MCP Server for Copilot CLI session
  - [ ] Create `dev/plans/prd.json` with initial bootstrap tasks
  - [ ] Create initial GitHub Issues for Phase 0 tasks (via `gh` or MCP)
  - [ ] Set up labels on repo (`agent-task`, `agent-claimed`, `agent-review`, `agent-blocked`, `auto-review`, persona labels, priority labels)
  - [ ] Run initial self-review to seed first issues
- [ ] Write `dev/harness/director.sh` — Main Director daemon (heartbeat loop):
  - [ ] Read open GitHub Issues labeled `agent-task` via `gh`/MCP
  - [ ] Read `dev/plans/prd.json` for spec-driven work
  - [ ] Manage parallel worktrees (up to MAX_WORKERS)
  - [ ] Dispatch agents to worktrees
  - [ ] Monitor worker completion
  - [ ] Trigger self-review when idle
  - [ ] PID file + graceful shutdown via SIGTERM/SIGINT
- [ ] Write `dev/harness/run-cycle.sh` — Single task cycle in worktree:
  - [ ] Read issue context via GitHub MCP
  - [ ] Invoke implementer/coder agent
  - [ ] Invoke QA agent for tests
  - [ ] Run `./scripts/build.sh && ./scripts/test.sh`
  - [ ] Create PR via GitHub MCP linking the issue
  - [ ] Invoke code-review agent on the PR
  - [ ] Record audit bundle
- [ ] Write `dev/harness/worktree.sh` — Worktree lifecycle helpers:
  - [ ] `create <branch>` — `git worktree add` in parent directory
  - [ ] `teardown <worktree_dir>` — `git worktree remove`
  - [ ] `list` — list active worktrees
- [ ] Write `dev/harness/review-self.sh` — Self-review bootstrap:
  - [ ] Run persona review agents on own codebase
  - [ ] Parse findings JSON
  - [ ] Create GitHub Issues for critical/high findings
  - [ ] Deduplicate against existing open issues
- [ ] Write `dev/harness/monitor-workers.sh` — Check worktree completion:
  - [ ] Detect completed workers
  - [ ] Validate build/test in worktree
  - [ ] Merge PRs for passing workers
  - [ ] Teardown completed worktrees
- [ ] Write `dev/harness/record-audit.sh` — Audit recording helper

### Agent Profiles
- [ ] Create `dev/agents/implementer.md` — Code writer agent prompt
- [ ] Create `dev/agents/coder.md` — Fix implementer agent prompt (issue→PR)
- [ ] Create `dev/agents/qa.md` — Test writer agent prompt
- [ ] Create `dev/agents/architect.md` — Architecture reviewer agent prompt
- [ ] Create `dev/agents/docs.md` — Documentation agent prompt
- [ ] Create `dev/agents/security.md` — Security auditor agent prompt
- [ ] Create `dev/agents/code-review.md` — Code reviewer agent prompt
- [ ] Create `.github/agents/` corresponding Copilot CLI agent definitions

### Initial Backlog
- [ ] Create `dev/plans/prd.json` — Initial task backlog (Phase 0 items)
- [ ] Verify Director can: read issues → create worktree → dispatch agent → create PR → merge

## Phase 1: Self-Review Loop (Self-Improvement Begins)

- [ ] Implement complete `dev/harness/review-self.sh`:
  - [ ] Run all persona agents (security, performance, architecture, testing, docs) on own code
  - [ ] Output findings as structured JSON
  - [ ] Create GitHub Issues for critical/high severity findings
  - [ ] Add appropriate labels (`auto-review`, persona, priority)
  - [ ] Deduplicate against existing open issues (avoid duplicates)
- [ ] Implement coding agent workflow:
  - [ ] Agent reads issue description via GitHub MCP
  - [ ] Agent creates fix branch `fix/<issue>-<desc>`
  - [ ] Agent implements fix in worktree
  - [ ] Agent writes tests for the fix
  - [ ] Agent runs build + test
  - [ ] Agent creates PR via GitHub MCP (`Closes #<issue>`)
  - [ ] Agent adds `agent-review` label for code-review
- [ ] Implement Director merge logic:
  - [ ] Code-review agent reviews PR
  - [ ] Director validates build/test pass
  - [ ] Director merges PR
  - [ ] Director closes linked issue
  - [ ] Director tears down worktree
- [ ] Verify circular loop: review → issue → fix → PR → merge → review
- [ ] Director runs indefinitely, self-improving the codebase

## Phase 2: Core App Skeleton (C++)

> Specs: `components/RunConfig.md`, `entities/AuditIdFactory.md`, `components/AuditRecord.md`, `components/PromptRecord.md`, `components/ReviewFinding.md`, `components/ReviewInput.md`

- [ ] `app/src/cli/main.cpp` — Entry point, arg parsing (subcommands: `demo`, `review`, `pr`, `fix`, `watch`, `ui`)
- [ ] `app/src/core/run_config.h/.cpp` — `RunConfig` struct: load from TOML, CLI flag overrides
- [ ] `app/src/core/audit_id_factory.h/.cpp` — `AuditIdFactory`: epoch-based UUID generation
- [ ] `app/src/core/audit_record.h/.cpp` — `AuditRecord` struct: JSON serialization
- [ ] `app/src/core/prompt_record.h/.cpp` — `PromptRecord` struct: prompt ledger
- [ ] `app/src/core/review_finding.h/.cpp` — `ReviewFinding` struct
- [ ] `app/src/core/review_input.h/.cpp` — `ReviewInput` struct: diff + metadata
- [ ] `app/config/reviewcat.example.toml` — Example config file
- [ ] `app/config/personas/` — Default persona prompt templates
- [ ] `reviewcat demo` — Bundled sample diff → persona review → markdown output
- [ ] Unit tests (Catch2): `test_run_config.cpp`, `test_audit_id.cpp`, `test_review_finding.cpp`

## Phase 3: Review Pipeline (C++)

> Specs: `systems/RepoDiffSystem.md`, `systems/CopilotRunnerSystem.md`, `systems/PersonaReviewSystem.md`, `systems/SynthesisSystem.md`, `systems/AuditStoreSystem.md`, `systems/CodingAgentSystem.md`, `entities/PromptFactory.md`

- [ ] `RepoDiffSystem` — `libgit2` or `git diff` subprocess, diff chunking
- [ ] `CopilotRunnerSystem` — `copilot -p` subprocess wrapper with MCP config:
  - [ ] Capture stdout/stderr, exit code
  - [ ] JSON response parsing and validation
  - [ ] Record/replay mode for deterministic testing
  - [ ] Prompt ledger recording
- [ ] `PromptFactory` — Build prompts from persona templates + diff chunks
- [ ] `PersonaReviewSystem` — Iterate personas, call CopilotRunner, validate JSON
- [ ] `SynthesisSystem` — Dedupe, prioritize, unified markdown, action plan JSON
- [ ] `CodingAgentSystem` — Dispatch coding agents to fix findings:
  - [ ] Create GitHub Issue from finding (via GitHub MCP)
  - [ ] Dispatch coding agent in worktree
  - [ ] Create PR linking issue
- [ ] `AuditStoreSystem` — Write artifacts, maintain index
- [ ] `reviewcat review <path>` end-to-end
- [ ] Integration tests with record/replay

## Phase 4: GitHub Integration (Runtime)

> Specs: `systems/GitHubOpsSystem.md`

- [ ] `GitHubOpsSystem` via GitHub MCP Server:
  - [ ] Create issues from review findings
  - [ ] Create PRs from coding agent fixes
  - [ ] Post unified review comments on PRs
  - [ ] Read PR diffs, issue descriptions
  - [ ] Handle rate limits, token validation
  - [ ] Fallback to `gh` CLI if MCP unavailable
- [ ] `reviewcat pr <PR#>` — Review a PR end-to-end
- [ ] `reviewcat watch` — Daemon mode: poll, auto-review, auto-fix
  - [ ] Configurable poll interval
  - [ ] PID file + graceful shutdown
  - [ ] Circular: review → issues → coding agent → PR → merge → review
- [ ] Support remote user repos (not just self-review)

## Phase 5: Patch Automation

> Specs: `systems/PatchApplySystem.md`

- [ ] `PatchApplySystem`:
  - [ ] Generate unified diffs from Copilot fix suggestions
  - [ ] Dry-run in temp worktree
  - [ ] Apply with backup + safety checks
- [ ] `reviewcat fix <path>` — Review + auto-apply patches

## Phase 6: End-User UI (C++)

- [ ] Set up Dear ImGui with SDL2 or GLFW backend in `app/src/ui/`
- [ ] Dashboard panel — active review status, recent findings, daemon health
- [ ] Settings panel — load/save `reviewcat.toml`
- [ ] Stats panel — review counts, severity breakdown, persona activity
- [ ] Audit Log panel — browse past runs, view findings
- [ ] Controls panel — start/stop daemon, trigger manual review
- [ ] `reviewcat ui` subcommand

## Phase 7: Polish & Distribution

- [ ] Single static binary via static linking
- [ ] Comprehensive error messages and `spdlog`-based logging
- [ ] End-user documentation (`docs/USAGE.md`, `docs/CONFIGURATION.md`)
- [ ] CI/CD pipeline (GitHub Actions): CMake build, Catch2 tests, static analysis
- [ ] README: build instructions, quick start, screenshots

---

## Cross-Cutting Concerns

- [ ] Establish C++ code style (`clang-format` config)
- [ ] Set up `clang-tidy` for static analysis
- [ ] Add `compile_commands.json` generation in CMake
- [ ] Document WSL prerequisites (Ubuntu packages, Copilot CLI, GitHub MCP)
- [ ] Configure GitHub MCP Server for dev agents (document in `dev/scripts/`)
- [ ] Security: never log or store tokens; redact sensitive paths in audits

---

## Notes

- **Dev harness** items (Phase 0–1) are all **bash/shell** — no C++ compilation needed.
- **App** items (Phase 2–7) are all **C++** — require CMake build.
- Phase 0 is the **highest priority** — get the Director running so it can autonomously implement Phases 1+.
- Phase 1 enables the **self-improvement loop** — ReviewCat reviews and fixes itself.
- All agent work is tracked via **GitHub Issues and PRs** on `p3nGu1nZz/Review-Cat`.
- Agents run in parallel via **git worktrees** in the parent directory.
- The `dev/` agents use **GitHub MCP Server** for issue/PR operations.
- Mark items `[x]` as they are completed; primary tracking is via GitHub Issues.
