# ReviewCat Implementation Checklist

This is a practical checklist aligned to [PLAN.md](../PLAN.md) and the
[design doc](COPILOT_CLI_CHALLENGE_DESIGN.md). It is intentionally explicit and
sequential.

> **Tech stack:** C++17/20, CMake, bash shell scripts. See PLAN.md §3 and §10.

## Phase 0: Repository Bootstrap & Dev Harness

- [ ] Create `app/` directory hierarchy:
  - [ ] `app/src/core/`, `app/src/cli/`, `app/src/daemon/`, `app/src/ui/`, `app/src/copilot/`
  - [ ] `app/include/`, `app/tests/`, `app/config/`, `app/scripts/`
  - [ ] `app/CMakeLists.txt` with targets: `reviewcat` binary, `reviewcat_core` lib, `reviewcat_tests`
- [ ] Create `dev/` directory hierarchy:
  - [ ] `dev/agents/`, `dev/harness/`, `dev/plans/`, `dev/prompts/`, `dev/scripts/`, `dev/audits/`
- [ ] Write root `CMakeLists.txt` (delegates to `app/CMakeLists.txt`).
- [ ] Set up dependency management (vcpkg or git submodules) for:
  - [ ] `nlohmann/json`, `toml++`, `Catch2`, `libgit2`, `imgui`, `SDL2/GLFW`, `spdlog`
- [ ] Write `scripts/build.sh` — CMake configure + build.
- [ ] Write `scripts/test.sh` — run Catch2 test binary.
- [ ] Write `scripts/clean.sh` — remove build artifacts.
- [ ] Write `dev/harness/director.sh` — heartbeat daemon skeleton.
- [ ] Write `dev/harness/run-cycle.sh` — agent cycle orchestration.
- [ ] Write `dev/scripts/bootstrap.sh` — one-shot dev env setup.
- [ ] Create agent profiles in `.github/agents/` and `dev/agents/`.
- [ ] Create `dev/plans/prd.json` initial backlog.
- [ ] Add a minimal `reviewcat --help` with command stubs.
- [ ] Create `.gitignore` (build/, *.o, *.a, etc.).
- [ ] Verify `./scripts/build.sh && ./scripts/test.sh` works (empty project compiles).

## Phase 1: Director Agent (Agent 0)

- [ ] Implement Director heartbeat loop in `dev/harness/director.sh`:
  - [ ] Read `dev/plans/prd.json` for backlog.
  - [ ] Pick highest-priority incomplete item.
  - [ ] Invoke `dev/harness/run-cycle.sh`.
  - [ ] Run `./scripts/build.sh && ./scripts/test.sh` as validation gate.
  - [ ] On success: mark complete, `git commit`.
  - [ ] On failure: retry (max 3), log, skip.
  - [ ] Sleep for configurable interval.
- [ ] Implement `dev/harness/run-cycle.sh`:
  - [ ] Call role agents via `copilot -p @dev/agents/<role>.md "..."`.
  - [ ] Capture output to `dev/audits/<bundle>/ledger/`.
- [ ] Implement `dev/harness/record-audit.sh`:
  - [ ] Bundle: ledger + build/test logs + diff.
  - [ ] Write `dev/audits/index.json`.
- [ ] Write Director-facing prompt templates in `dev/prompts/`.
- [ ] Test Director with a trivial spec.

## Phase 2: Core App Skeleton (C++)

- [ ] `app/src/cli/main.cpp` — entry point, arg parsing (`demo`, `review`, `pr`, `fix`, `watch`, `ui`).
- [ ] `app/src/core/run_config.h/.cpp` — `RunConfig` struct (TOML → `toml++`).
- [ ] `app/src/core/audit_id_factory.h/.cpp` — epoch-based UUID generation.
- [ ] `app/src/core/audit_record.h/.cpp` — JSON serialization (`nlohmann/json`).
- [ ] `app/src/core/prompt_record.h/.cpp` — prompt ledger.
- [ ] `app/src/core/review_finding.h/.cpp` — finding struct.
- [ ] `app/src/core/review_input.h/.cpp` — diff + metadata.
- [ ] `app/config/reviewcat.example.toml` — annotated example config.
- [ ] `app/config/personas/` — default persona prompt templates.
- [ ] `reviewcat demo` — bundled sample diff → review → markdown.
- [ ] Unit tests: `test_run_config.cpp`, `test_audit_id.cpp`, `test_review_finding.cpp` (Catch2).

## Phase 3: Review Pipeline (C++)

- [ ] `RepoDiffSystem` — `libgit2` or `git diff` subprocess, diff chunking.
- [ ] `CopilotRunnerSystem` — `copilot -p` subprocess wrapper:
  - [ ] capture stdout/stderr, exit code
  - [ ] JSON response parsing and validation
  - [ ] record/replay mode for deterministic testing
  - [ ] prompt ledger recording
- [ ] `PromptFactory` — build prompts from persona templates + diff chunks.
- [ ] `PersonaReviewSystem` — iterate personas, call CopilotRunner, validate JSON.
- [ ] `SynthesisSystem` — dedupe, prioritize, unified markdown, action plan JSON.
- [ ] `AuditStoreSystem` — write artifacts, maintain index.
- [ ] `reviewcat review <path>` end-to-end.
- [ ] Integration tests with record/replay.

## Phase 4: GitHub Integration

- [ ] `GitHubOpsSystem` via `gh` CLI:
  - [ ] fetch PR diff (`gh pr diff`)
  - [ ] post unified comment (`gh pr comment`)
  - [ ] create issues (`gh issue create`)
  - [ ] handle rate limits, token validation
- [ ] `reviewcat pr <PR#>`.
- [ ] `reviewcat watch` — daemon mode (poll interval, PID file, graceful shutdown).

## Phase 5: Patch Automation

- [ ] `PatchApplySystem`:
  - [ ] generate unified diffs from fix suggestions
  - [ ] dry-run in temp worktree
  - [ ] apply with backup + safety checks
- [ ] `reviewcat fix <path>`.

## Phase 6: End-User UI (C++)

- [ ] Set up Dear ImGui with SDL2 or GLFW backend in `app/src/ui/`.
- [ ] Dashboard panel — active review status, recent findings, daemon health.
- [ ] Settings panel — load/save `reviewcat.toml`:
  - [ ] Copilot credentials, GitHub access token, target repo, base branch
  - [ ] Review interval, personas enabled/disabled, auto-comment, auto-fix
  - [ ] Redaction rules
- [ ] Stats panel — review counts, severity breakdown, persona activity.
- [ ] Audit Log panel — browse past runs, view findings.
- [ ] Controls panel — start/stop daemon, trigger manual review.
- [ ] `reviewcat ui` subcommand to launch the window.

## Phase 7: Polish & Distribution

- [ ] Produce single static binary (`reviewcat`) via static linking.
- [ ] Comprehensive error messages and `spdlog`-based logging.
- [ ] End-user documentation (`docs/USAGE.md`, `docs/CONFIGURATION.md`).
- [ ] Man page or `--help` with detailed subcommand docs.
- [ ] CI/CD pipeline (GitHub Actions): CMake build, Catch2 tests, static analysis.
- [ ] README: one-command demo, build instructions, quick start, troubleshooting.
- [ ] Include example artifacts (or screenshots) in the repo.
