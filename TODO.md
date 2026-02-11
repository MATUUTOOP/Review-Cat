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

> **Goal:** Go from docs-only repo to a self-coding Director daemon — like
> Claude Code but autonomous. Every subsection below is ordered by dependency.
> Complete them top-to-bottom.

### 0.1 — Environment & Toolchain (prereqs before anything else)

- [ ] Install/verify **Copilot CLI**: `copilot --version` (requires GitHub Copilot subscription)
- [ ] Install **gh CLI**: `sudo apt install gh` → `gh --version`
- [ ] Authenticate gh CLI: `gh auth login` (select HTTPS, `repo` scope, confirm with browser)
- [ ] Install **jq**: `sudo apt install jq` → `jq --version`
- [ ] Verify **cmake**: `cmake --version` (already installed)
- [ ] Verify **g++**: `g++ --version` (already installed)
- [ ] Verify **docker**: `docker --version` (already installed — needed for GitHub MCP Server)
- [ ] Create a GitHub **Personal Access Token** (PAT) with `repo` scope
- [ ] Export PAT: `export GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...` (add to `~/.bashrc`)
- [ ] Verify Copilot CLI works: `copilot -p "Say hello and confirm you can see this prompt"`
- [ ] Verify gh works: `gh issue list --repo p3nGu1nZz/Review-Cat`

### 0.2 — GitHub MCP Server Configuration (gives agents GitHub superpowers)

- [ ] Pull MCP Server Docker image: `docker pull ghcr.io/github/github-mcp-server`
- [ ] Create `dev/mcp/github-mcp.json` — MCP config file:
  ```json
  {
    "mcpServers": {
      "github": {
        "command": "docker",
        "args": [
          "run", "-i", "--rm",
          "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
          "ghcr.io/github/github-mcp-server",
          "--toolsets", "issues,pull_requests,repos,git"
        ],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": ""
        }
      }
    }
  }
  ```
- [ ] Smoke-test MCP read: `copilot -p "List open issues on p3nGu1nZz/Review-Cat using GitHub MCP tools" --mcp-config dev/mcp/github-mcp.json`
- [ ] Smoke-test MCP write: `copilot -p "Create a GitHub Issue titled '[test] MCP smoke test' with body 'Delete me' on p3nGu1nZz/Review-Cat" --mcp-config dev/mcp/github-mcp.json`
- [ ] Close/delete the smoke-test issue
- [ ] Smoke-test agent + MCP + file write:
  ```bash
  copilot -p "Create a file called /tmp/mcp-test.txt containing 'hello from copilot'. \
    Then list open issues on p3nGu1nZz/Review-Cat via GitHub MCP." \
    --mcp-config dev/mcp/github-mcp.json --allow-tools write
  ```
  This proves the agent can **read/write files AND talk to GitHub** — the two core capabilities needed for self-coding.
- [ ] Set up label taxonomy on the repo (via `gh` or MCP):
  - `agent-task`, `agent-claimed`, `agent-review`, `agent-blocked`, `auto-review`
  - `security`, `performance`, `architecture`, `testing`, `docs`
  - `priority-critical`, `priority-high`, `priority-medium`, `priority-low`

### 0.3 — Directory Structure & Build Scaffold

- [ ] Create `app/` hierarchy: `src/core/`, `src/cli/`, `src/daemon/`, `src/ui/`, `src/copilot/`, `include/`, `tests/`, `config/`, `scripts/`
- [ ] Create `dev/` hierarchy: `agents/`, `harness/`, `plans/`, `prompts/`, `scripts/`, `audits/`, `mcp/`
- [ ] Create `.github/agents/` for Copilot CLI repo-level agent profiles
- [ ] Create `.gitignore`:
  ```
  build/
  *.o
  *.a
  *.so
  Review-Cat-agent-*/
  dev/audits/*/
  .env
  ```
- [ ] Write root `CMakeLists.txt` (delegates to `app/CMakeLists.txt`)
- [ ] Write `app/CMakeLists.txt` with targets: `reviewcat` binary, `reviewcat_core` lib, `reviewcat_tests`

### 0.4 — Minimal C++ Scaffold (build gate must pass from day 1)

The Director's build/test validation gate runs `scripts/build.sh && scripts/test.sh`
on every agent cycle. We need a minimal compilable project so this gate passes
immediately — even before any real app code exists.

- [ ] Write `app/src/cli/main.cpp` — Minimal main:
  ```cpp
  #include <iostream>
  int main(int argc, char* argv[]) {
      if (argc > 1 && std::string(argv[1]) == "--version") {
          std::cout << "reviewcat 0.0.1-bootstrap" << std::endl;
          return 0;
      }
      std::cout << "ReviewCat — autonomous code review daemon" << std::endl;
      std::cout << "Usage: reviewcat [demo|review|pr|fix|watch|ui]" << std::endl;
      return 0;
  }
  ```
- [ ] Write `scripts/build.sh`:
  ```bash
  #!/usr/bin/env bash
  set -e
  mkdir -p build && cd build
  cmake .. -DCMAKE_BUILD_TYPE=Debug
  cmake --build . --parallel "$(nproc)"
  ```
- [ ] Write `scripts/test.sh`:
  ```bash
  #!/usr/bin/env bash
  set -e
  if [ -f build/reviewcat_tests ]; then
      ./build/reviewcat_tests
  else
      echo "No test binary yet — scaffold pass"
      exit 0
  fi
  ```
- [ ] Write `scripts/clean.sh` — `rm -rf build/`
- [ ] Verify: `./scripts/build.sh && ./scripts/test.sh` passes (green gate)
- [ ] Verify: `./build/reviewcat --version` prints `0.0.1-bootstrap`

### 0.5 — Agent Profiles (the "system prompts" that make agents code like Claude Code)

These are the prompt files that define each agent's identity, capabilities,
rules, and output format. They are the equivalent of Claude Code's system
prompt — they tell the LLM what it is and how to behave.

- [ ] Create `dev/agents/coder.md` — **CRITICAL, this is the core coding agent**:
  - Identity: "You are a coding agent for the ReviewCat project"
  - Capabilities: read/write files, run shell commands, use GitHub MCP tools
  - Context: C++17/20, CMake, nlohmann/json, toml++, Catch2, project structure
  - Rules: only modify files in your worktree, follow specs, write tests
  - Output: working code + tests that pass `scripts/build.sh && scripts/test.sh`
  - MCP tools: `get_issue`, `create_pull_request`, `add_issue_comment`
- [ ] Create `dev/agents/implementer.md` — Writes new features from specs
- [ ] Create `dev/agents/code-review.md` — Reviews PRs, posts review comments
- [ ] Create `dev/agents/qa.md` — Writes Catch2 tests, creates fixtures
- [ ] Create `dev/agents/architect.md` — Reviews architecture, complexity
- [ ] Create `dev/agents/security.md` — Finds vulnerabilities, unsafe patterns
- [ ] Create `dev/agents/docs.md` — Maintains documentation
- [ ] Create `.github/agents/reviewcat.md` — Repo-level Copilot agent definition
- [ ] Verify agent invocation works:
  ```bash
  copilot -p @dev/agents/coder.md \
    "Read the file PLAN.md and summarize the Phase 0 tasks" \
    --mcp-config dev/mcp/github-mcp.json
  ```

### 0.6 — Core Harness Scripts (the orchestration that makes it autonomous)

These scripts are what transform Copilot CLI from a manual tool into an
autonomous coding agent. Without them, you have Claude Code with no loop.
With them, you have a self-driving development daemon.

- [ ] Write `dev/harness/worktree.sh` — Worktree lifecycle helpers:
  - [ ] `create <branch>` — `git worktree add ../Review-Cat-${branch} -b ${branch}`
  - [ ] `teardown <worktree_dir>` — `git worktree remove --force`
  - [ ] `list` — `git worktree list --porcelain`
  - [ ] `count` — count active worktrees
  - [ ] Validate MAX_WORKERS limit before creating
- [ ] Write `dev/harness/run-cycle.sh` — Single task cycle (the "Claude Code session"):
  - [ ] Accept args: `<issue_number> <branch_name>`
  - [ ] `cd` into the worktree for this branch
  - [ ] Create audit dir: `dev/audits/$(date +%Y%m%d-%H%M%S)-${issue}/`
  - [ ] Invoke coder agent with issue context + MCP + file write:
    ```bash
    copilot -p @dev/agents/coder.md \
      "Fix issue #${ISSUE} on p3nGu1nZz/Review-Cat. \
       Read the issue via GitHub MCP. Implement the fix. Write tests. \
       Ensure scripts/build.sh && scripts/test.sh pass." \
      --mcp-config dev/mcp/github-mcp.json \
      --allow-tools write \
      2>&1 | tee "$AUDIT_DIR/ledger/coder.txt"
    ```
  - [ ] Run `./scripts/build.sh && ./scripts/test.sh` (validation gate)
  - [ ] On success: `git add -A && git commit -m "fix(#${ISSUE}): ..."`
  - [ ] On success: invoke PR creation via MCP:
    ```bash
    copilot -p "Create a PR from branch '${BRANCH}' to main on \
      p3nGu1nZz/Review-Cat. Title: 'fix(#${ISSUE}): ...' \
      Body: 'Closes #${ISSUE}'. Use GitHub MCP tools." \
      --mcp-config dev/mcp/github-mcp.json \
      2>&1 | tee "$AUDIT_DIR/ledger/pr-create.txt"
    ```
  - [ ] Invoke code-review agent on the PR
  - [ ] Record audit bundle
- [ ] Write `dev/harness/review-self.sh` — Self-review (creates work for the loop):
  - [ ] Generate diff: `git diff HEAD~5..HEAD` (or full tree on first run)
  - [ ] For each persona (security, performance, architecture, testing, docs):
    ```bash
    copilot -p @dev/agents/${PERSONA}-review.md \
      "Review this code for ${PERSONA} concerns. Output JSON array: \
       [{title, description, severity, file, line_start, suggested_fix}]" \
      --stdin <<< "$DIFF" > /tmp/reviewcat-self-${PERSONA}.json
    ```
  - [ ] Filter findings: only `critical` and `high` severity
  - [ ] Deduplicate: compare titles against existing open issues (`gh issue list`)
  - [ ] Create GitHub Issues for new findings via MCP with labels
- [ ] Write `dev/harness/monitor-workers.sh` — Worker completion check:
  - [ ] List active worktrees
  - [ ] For each: check if agent process is still running
  - [ ] For completed workers: validate build/test passed
  - [ ] For passing workers: merge PR via MCP, close issue, teardown worktree
  - [ ] For failing workers: increment retry counter, re-dispatch or label `agent-blocked`
- [ ] Write `dev/harness/record-audit.sh` — Audit recording:
  - [ ] Collect: ledger files, build.log, test.log, `git diff`
  - [ ] Write audit summary JSON
  - [ ] Update `dev/audits/index.json`

### 0.7 — Director Daemon (the heartbeat loop — Agent 0 comes alive)

- [ ] Write `dev/harness/director.sh` — The main daemon:
  - [ ] Config variables at top: `INTERVAL=60`, `MAX_WORKERS=3`, `MAX_RETRIES=3`, `REPO=p3nGu1nZz/Review-Cat`
  - [ ] PID file: write `$$` to `dev/harness/director.pid`, check on startup
  - [ ] Trap `SIGTERM`/`SIGINT` for graceful shutdown (teardown all worktrees)
  - [ ] **Main loop** (`while true`):
    1. Scan open issues labeled `agent-task` via `gh issue list` (MCP fallback)
    2. Check `dev/plans/prd.json` for spec-driven work
    3. Count active worktrees via `dev/harness/worktree.sh count`
    4. For each available worker slot + unclaimed issue:
       - Claim issue: add `agent-claimed` label, remove `agent-task`
       - Create branch: `agent/${ISSUE}-$(date +%s)`
       - Create worktree: `dev/harness/worktree.sh create $BRANCH`
       - Dispatch: `dev/harness/run-cycle.sh $ISSUE $BRANCH &`
    5. Monitor completed workers: `dev/harness/monitor-workers.sh`
    6. If no issues and no PDR tasks and all workers idle:
       - Run `dev/harness/review-self.sh` (creates new issues → feeds the loop)
    7. `sleep $INTERVAL`
  - [ ] Log each heartbeat iteration to `dev/audits/director.log`

### 0.8 — Bootstrap Script (one command to set everything up)

- [ ] Write `dev/scripts/bootstrap.sh` — One-shot setup:
  - [ ] Verify all prereqs: `copilot`, `gh`, `jq`, `cmake`, `g++`, `docker`
  - [ ] Verify `GITHUB_PERSONAL_ACCESS_TOKEN` is set
  - [ ] Verify gh is authenticated: `gh auth status`
  - [ ] Pull MCP Server image: `docker pull ghcr.io/github/github-mcp-server`
  - [ ] Create `dev/mcp/github-mcp.json` if missing
  - [ ] Create label taxonomy on repo (idempotent — skip existing labels)
  - [ ] Create `dev/plans/prd.json` with initial bootstrap tasks
  - [ ] Create initial GitHub Issues for remaining Phase 0 items
  - [ ] Run `./scripts/build.sh` to verify C++ scaffold compiles
  - [ ] Run `dev/harness/review-self.sh` to seed first issues
  - [ ] Print: "Bootstrap complete. Run: ./dev/harness/director.sh"

### 0.9 — Initial Backlog & First Issues

- [ ] Create `dev/plans/prd.json` — Initial task backlog mapping Phase 0 items
- [ ] Create seed GitHub Issues manually or via bootstrap:
  - Issue: "Implement RunConfig TOML parsing" → `agent-task`, `architecture`
  - Issue: "Implement AuditIdFactory" → `agent-task`, `architecture`
  - Issue: "Add --help and subcommand stubs to CLI" → `agent-task`, `docs`
  - Issue: "Write first Catch2 unit test" → `agent-task`, `testing`
  - Issue: "Implement CopilotRunnerSystem subprocess wrapper" → `agent-task`, `architecture`

### 0.10 — End-to-End Smoke Test (Director self-codes for the first time)

This is the acceptance test for Phase 0. If this passes, you have a self-coding
system equivalent to running Claude Code in an autonomous loop.

- [ ] Run `./dev/scripts/bootstrap.sh` — verify clean exit
- [ ] Run `./dev/harness/director.sh` — let it execute **one full heartbeat**
- [ ] Verify: Director read open issues (printed to log)
- [ ] Verify: Director created a worktree for an issue
- [ ] Verify: Copilot CLI agent was invoked in the worktree with `--allow-tools write`
- [ ] Verify: Agent produced code changes (files modified in worktree)
- [ ] Verify: `scripts/build.sh` ran in worktree (CMake output in audit log)
- [ ] Verify: `scripts/test.sh` ran in worktree
- [ ] Verify: Agent created a PR via GitHub MCP (PR visible on GitHub)
- [ ] Verify: Code-review agent posted a review comment on the PR
- [ ] Verify: Director merged the PR (or flagged for human review)
- [ ] Verify: Director tore down the worktree after merge
- [ ] Verify: Audit bundle exists under `dev/audits/` with ledger files
- [ ] Run `dev/harness/review-self.sh` independently — verify it creates ≥1 issue
- [ ] Let Director run for 3+ heartbeats — verify the circular loop:
  - Self-review creates issues → agent fixes them → PRs merged → self-review again
- [ ] **MILESTONE: Director is autonomously coding. Phase 0 complete.**

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
