# ReviewCat: Comprehensive Project Plan

> **Golden Source of Truth** — This document, together with `TODO.md` and the
> specs under `docs/specs/`, defines what ReviewCat is, how it is built, and how
> it operates at runtime. All implementation must trace back to these docs.

## 1. Vision

ReviewCat is an **autonomous, AI-powered code review daemon** that:

1. **Monitors** a user's GitHub repository for changes (commits, PRs).
2. **Reviews** diffs using persona-based Copilot CLI agents (security,
   performance, architecture, testing, docs).
3. **Synthesizes** findings into unified reviews, action plans, and optional
   patches.
4. **Creates** PRs, issues, and comments on behalf of the user.
5. **Provides** a local UI window for settings, stats, and command-and-control.

ReviewCat is also **self-building**: it uses a development harness powered by
GitHub Copilot CLI to autonomously develop, test, and iterate on its own
codebase.

## 2. Two-Part Architecture

The repository is split into two top-level sections:

```
Review-Cat/
├── app/                    # The product — what end users run
│   ├── src/                # C++ application source code
│   │   ├── core/           # Core library (components, entities, systems)
│   │   ├── cli/            # CLI frontend (main, arg parsing)
│   │   ├── daemon/         # Daemon / watch mode
│   │   ├── ui/             # UI window (imgui or similar)
│   │   └── copilot/        # Copilot CLI subprocess bridge
│   ├── include/            # Public C++ headers
│   ├── tests/              # C++ test suite (Catch2)
│   ├── config/             # Default configs, persona templates
│   ├── scripts/            # Build, test, package shell scripts
│   └── CMakeLists.txt      # App build system
│
├── dev/                    # The meta-tooling — what builds the product
│   ├── agents/             # Development role agent prompt files
│   ├── harness/            # Heartbeat daemon shell scripts
│   ├── plans/              # PRD items, task graphs, progress tracking
│   ├── prompts/            # Prompt templates for dev agents
│   ├── scripts/            # Dev harness bootstrap and utility scripts
│   └── audits/             # Development audit bundles
│
├── .github/
│   └── agents/             # Copilot CLI custom agent definitions
│
├── docs/                   # Design docs and specifications (golden source)
│   ├── specs/              # Component, entity, system, agent specs
│   ├── COPILOT_CLI_CHALLENGE_DESIGN.md
│   ├── DIRECTOR_DEV_WORKFLOW.md
│   ├── IMPLEMENTATION_CHECKLIST.md
│   └── PROMPT_COOKBOOK.md
│
├── scripts/                # Top-level convenience scripts
│   ├── build.sh            # Build the app
│   ├── test.sh             # Run all tests
│   └── clean.sh            # Clean build artifacts
│
├── CMakeLists.txt          # Root CMake (delegates to app/)
├── PLAN.md                 # This file
├── TODO.md                 # Actionable task list
└── README.md               # Project overview and quick start
```

### 2.1. `app/` — The Product

This is the ReviewCat application that end users build and run. It contains:

- **CLI frontend** (`reviewcat` binary: `demo`, `review`, `pr`, `fix`, `watch`)
- **Daemon mode** — persistent background process that monitors a repo
- **UI window** — lightweight native window for settings, stats, and control
- **Runtime agents** — persona review agents powered by Copilot CLI subprocess calls
- **Audit system** — structured artifact output for every review run
- **GitHub integration** — create PRs, issues, comments via `gh` CLI

### 2.2. `dev/` — The Development Harness

This is the meta-tooling that builds ReviewCat autonomously. It is composed
entirely of **shell scripts** and **Copilot CLI agent profiles**:

- **Agent 0 (Director)** — the always-running orchestrator daemon (shell script)
- **Role agents** — Architect, Implementer, QA, Docs, Security, Code-Review
- **Heartbeat system** — persistent bash loop that keeps the Director alive
- **Progress tracking** — PRD items, task graphs, completion status (JSON files)
- **Development audits** — prompt ledgers and agent outputs for every dev cycle

## 3. Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Language | **C++17/20** | Fast native binary; no runtime deps; cross-platform |
| Build system | **CMake** | Industry standard for C++ projects |
| Shell scripts | **Bash** | Dev harness, agent orchestration, build/test/CI |
| UI toolkit | **Dear ImGui** (with SDL2/GLFW backend) | Lightweight immediate-mode GUI; single window; easy to embed |
| Copilot integration | **`copilot -p`** subprocess calls | Invoke Copilot CLI from C++ via `popen`/`fork+exec` or from shell scripts |
| Git ops | **libgit2** + **`gh` CLI** | Programmatic git from C++; GitHub API via `gh` |
| JSON | **nlohmann/json** | De facto C++ JSON library |
| Config | **TOML** (`reviewcat.toml`) | Human-readable; parsed with `toml++` |
| Testing | **Catch2** | Mature, header-only C++ test framework |
| Package manager | **vcpkg** or git submodules | Dependency management for C++ libs |
| Distribution | Single static binary + shell | No runtime dependencies for end users |

## 4. Agent Architecture

### 4.1. Development Agents (in `dev/`)

These are **shell scripts + Copilot CLI agent profiles** that run during
development to build ReviewCat itself. They do NOT require the C++ app to be
built — they operate purely via Copilot CLI and bash:

| Agent | Role | How It Runs |
|-------|------|-------------|
| **Director (Agent 0)** | Orchestrator | `dev/harness/director.sh` — bash heartbeat loop |
| **Architect** | Design reviewer | `copilot -p @dev/agents/architect.md "..."` |
| **Implementer** | Code writer | `copilot -p @dev/agents/implementer.md "..."` |
| **QA** | Test engineer | `copilot -p @dev/agents/qa.md "..."` |
| **Docs** | Documentation | `copilot -p @dev/agents/docs.md "..."` |
| **Security** | Security auditor | `copilot -p @dev/agents/security.md "..."` |
| **Code-Review** | Reviewer | `copilot -p @dev/agents/code-review.md "..."` |

### 4.2. Runtime Agents (in `app/`)

These run when end users use ReviewCat to review code. They are invoked by the
compiled C++ binary via Copilot CLI subprocess calls:

| Agent | Persona | Focus Area |
|-------|---------|-----------|
| **Security** | Vulnerability hunter | Exploitability, unsafe defaults, data leaks |
| **Performance** | Optimizer | Algorithmic complexity, hot paths, allocations |
| **Architecture** | Structural analyst | Module boundaries, naming, dependency direction |
| **Testing** | Test coverage analyst | Missing tests, concrete test case proposals |
| **Docs** | Documentation reviewer | Missing usage docs, confusing behaviors |

### 4.3. Copilot CLI Integration

Copilot CLI is invoked in two contexts:

1. **Development harness** (shell scripts) — `copilot -p "prompt"` called
   directly from bash. This is how the autonomous dev loop works. No C++ needed.
2. **Runtime app** (C++ binary) — The compiled `reviewcat` binary invokes
   `copilot -p "prompt"` as a subprocess, captures stdout/stderr, parses JSON
   responses, and writes the prompt ledger.

In both cases, the integration is via the **Copilot CLI subprocess** (`copilot`
command). There is no npm/node dependency.

## 5. Agent 0: The Director Daemon

### 5.1. Heartbeat System

Agent 0 is a **bash script** (`dev/harness/director.sh`) that runs in a loop:

```
┌─────────────────────────────────────────────┐
│          Director Daemon (bash)             │
│                                             │
│  ┌─────────┐    ┌──────────┐    ┌────────┐ │
│  │Heartbeat│───▶│  Check   │───▶│Execute │ │
│  │  Timer  │    │ Backlog  │    │ Cycle  │ │
│  └────┬────┘    └──────────┘    └────┬───┘ │
│       │                              │     │
│       │         ┌──────────┐         │     │
│       └────────▶│  Sleep   │◀────────┘     │
│                 │ Interval │               │
│                 └──────────┘               │
└─────────────────────────────────────────────┘
```

**Heartbeat loop (pseudocode):**

```bash
#!/usr/bin/env bash
# dev/harness/director.sh

INTERVAL=${DIRECTOR_INTERVAL:-60}
MAX_RETRIES=3

while true; do
    # 1. Check backlog
    TASK=$(jq -r '.[] | select(.passes == false) | .id' dev/plans/prd.json | head -1)

    if [ -z "$TASK" ]; then
        echo "[director] All tasks complete. Sleeping..."
        sleep "$INTERVAL"
        continue
    fi

    # 2. Load spec for the task
    SPEC=$(jq -r ".[] | select(.id == \"$TASK\") | .spec" dev/plans/prd.json)

    # 3. Run agent cycle
    ./dev/harness/run-cycle.sh "$TASK" "$SPEC"

    # 4. Validate (build + test)
    ./scripts/build.sh && ./scripts/test.sh
    if [ $? -eq 0 ]; then
        # Mark task complete
        jq "(.[] | select(.id == \"$TASK\")).passes = true" \
            dev/plans/prd.json > tmp.json && mv tmp.json dev/plans/prd.json
        git add -A && git commit -m "feat($TASK): implement spec $SPEC"
    fi

    # 5. Record audit
    ./dev/harness/record-audit.sh "$TASK"

    # 6. Sleep
    sleep "$INTERVAL"
done
```

### 5.2. Agent Cycle Script

`dev/harness/run-cycle.sh` orchestrates the role agents for a single task:

```bash
#!/usr/bin/env bash
# dev/harness/run-cycle.sh <task_id> <spec_path>

TASK=$1
SPEC=$2
AUDIT_DIR="dev/audits/$(date +%Y%m%d-%H%M%S)-${TASK}"
mkdir -p "$AUDIT_DIR/ledger"

# 1. Implementer writes code
copilot -p @dev/agents/implementer.md \
    "Implement the following spec: $(cat docs/specs/$SPEC)" \
    --allow-tools write \
    2>&1 | tee "$AUDIT_DIR/ledger/implementer.txt"

# 2. QA writes tests
copilot -p @dev/agents/qa.md \
    "Write tests for the spec: $(cat docs/specs/$SPEC)" \
    --allow-tools write \
    2>&1 | tee "$AUDIT_DIR/ledger/qa.txt"

# 3. Docs updates documentation
copilot -p @dev/agents/docs.md \
    "Update docs for: $(cat docs/specs/$SPEC)" \
    --allow-tools write \
    2>&1 | tee "$AUDIT_DIR/ledger/docs.txt"

# 4. Security review
copilot -p @dev/agents/security.md \
    "Security review for changes related to: $(cat docs/specs/$SPEC)" \
    2>&1 | tee "$AUDIT_DIR/ledger/security.txt"

# 5. Code review
copilot -p @dev/agents/code-review.md \
    "Review the diff: $(git diff HEAD)" \
    2>&1 | tee "$AUDIT_DIR/ledger/code-review.txt"
```

### 5.3. Guardrails

- **Dry-run default** — no `git push`, no GitHub mutations without explicit opt-in.
- **Scope lock** — Director refuses to modify files outside the spec's scope.
- **Retry budget** — Max 3 retries per sub-task before marking failed.
- **Dangerous command deny list** — `rm -rf`, `git push --force`, etc.
- **Watchdog** — If a cycle exceeds timeout, Director kills the subprocess.
- **Permission profiles** — Copilot CLI `--allow-tools` / `--deny-tools` flags.

### 5.4. Bootstrap Sequence

To cold-start the Director for the first time:

```bash
# 1. Clone and enter the repo
cd Review-Cat

# 2. Bootstrap the dev harness
./dev/scripts/bootstrap.sh

# 3. Start the Director daemon (runs in background)
nohup ./dev/harness/director.sh &
# Or interactively:
./dev/harness/director.sh
```

The Director reads `dev/plans/prd.json` for its initial work items and begins
executing cycles autonomously.

## 6. End-User UI

### 6.1. UI Window

A native window built with **Dear ImGui** (SDL2 or GLFW backend) provides:

- **Dashboard** — Active review status, recent findings, daemon health.
- **Settings** — Copilot credentials, GitHub access token, target repo, persona
  selection, review interval, notification preferences.
- **Stats** — Review counts, finding trends, persona breakdown, agent uptime.
- **Agent Personas** — Enable/disable personas, adjust severity thresholds.
- **Audit Log** — Browse past review runs and their artifacts.
- **Controls** — Start/stop daemon, trigger manual review, open audit directory.

The UI is compiled into the `reviewcat` binary. Running `reviewcat ui` opens the
window. The daemon can run headless (no UI) via `reviewcat watch`.

### 6.2. Settings Screen

End users configure:

| Setting | Description |
|---------|------------|
| Copilot credentials | Authentication for Copilot CLI |
| GitHub access token | PAT for creating PRs, issues, comments |
| Target repository | `OWNER/REPO` to monitor |
| Base branch | Default branch for diff comparison |
| Review interval | How often the daemon checks for changes (seconds) |
| Personas enabled | Which review personas to run |
| Auto-comment | Whether to post unified review as PR comment |
| Auto-fix | Whether to generate and apply patches |
| Redaction rules | Glob patterns for sensitive files to exclude |

Settings are stored in `reviewcat.toml` (user-editable, no secrets in repo).

## 7. Core Review Pipeline (Runtime)

```
 User's Repo
      │
      ▼
 ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
 │ RepoDiff │───▶│ Persona  │───▶│Synthesis │───▶│  Audit   │
 │  System  │    │ Review   │    │  System  │    │  Store   │
 └──────────┘    │  System  │    └──────────┘    └──────────┘
                 └──────────┘           │
                                        ▼
                                 ┌──────────┐
                                 │ GitHub   │
                                 │   Ops    │
                                 └──────────┘
```

1. **RepoDiffSystem** — Collect diffs via `libgit2` or `git` subprocess.
2. **PersonaReviewSystem** — Run persona agents via `copilot -p` subprocess.
3. **SynthesisSystem** — Deduplicate, prioritize, unify findings (C++).
4. **AuditStoreSystem** — Write artifacts to disk, update index.
5. **GitHubOpsSystem** — Post comments, create issues/PRs via `gh` (opt-in).
6. **PatchApplySystem** — Generate and apply safe patches (opt-in).

All systems are implemented as C++ classes following the ECS-style separation.

## 8. Development Workflow

### 8.1. Spec-First Development

All development follows the spec-first pattern:

1. Write or update a spec in `docs/specs/`.
2. Director reads the spec and extracts requirements + acceptance criteria.
3. Director assigns sub-tasks to role agents (via Copilot CLI).
4. Agents implement, test, and document.
5. Director validates via `./scripts/build.sh && ./scripts/test.sh`.
6. Director commits and records audit.

### 8.2. Development Loop (Ralph-Inspired)

The Director uses a loop pattern inspired by the
[Ralph Wiggum technique](https://www.humanlayer.dev/blog/brief-history-of-ralph):

1. **Read** — Load PRD and progress state from JSON files.
2. **Pick** — Choose highest-priority incomplete item.
3. **Implement** — Delegate to Copilot CLI role agents.
4. **Verify** — Run `./scripts/build.sh && ./scripts/test.sh`.
5. **Update** — Mark item complete in `dev/plans/prd.json`.
6. **Commit** — `git add -A && git commit -m "..."`.
7. **Repeat** — Until all items pass or retry budget exhausted.

### 8.3. Agent Orchestration (CEO-Inspired)

Drawing from the [CEO Orchestration System](https://github.com/ivfarias/ceo):

- Agent profiles are defined as markdown files in `.github/agents/`.
- The Director (Agent 0) acts as the CEO: it delegates to specialist agents.
- Agents communicate via file-based artifacts (specs, code, test results).
- No npm, no Node.js — pure shell + Copilot CLI.

### 8.4. Parallel Execution (Swarm-Inspired)

Drawing from [Copilot Swarm Orchestrator](https://github.com/moonrunnerkc/copilot-swarm-orchestrator):

- Independent tasks can run in parallel on isolated git branches.
- Each agent's work is verified by build/test results.
- Verified branches merge back to main.

## 9. Phased Implementation Plan

### Phase 0: Repository Bootstrap & Dev Harness
- Create `app/` and `dev/` directory structure.
- Set up CMake build system for C++ project.
- Create `scripts/build.sh`, `scripts/test.sh`, `scripts/clean.sh`.
- Create `dev/harness/director.sh` (heartbeat daemon skeleton).
- Create `dev/harness/run-cycle.sh` (agent cycle orchestration).
- Define agent profiles in `.github/agents/` and `dev/agents/`.
- Create `dev/plans/prd.json` initial backlog.
- Verify `./scripts/build.sh && ./scripts/test.sh` works.

### Phase 1: Director Agent (Agent 0)
- Implement Director heartbeat loop in bash.
- Implement spec reader (extract tasks from markdown specs via shell).
- Implement task decomposition (spec → Copilot CLI agent calls).
- Implement sequential agent execution with checkpoints.
- Implement build/test validation runner.
- Implement development audit recording.
- Implement progress tracking (`dev/plans/prd.json` updates via `jq`).

### Phase 2: Core App Skeleton (C++)
- Implement CLI frontend (`main.cpp`, arg parsing).
- Implement `RunConfig` component (TOML parsing via `toml++`).
- Implement `AuditIdFactory` and `AuditStoreSystem`.
- Implement prompt ledger (`PromptRecord` as JSON via `nlohmann/json`).
- Implement `ReviewFinding` and `ReviewInput` components.
- Implement `reviewcat demo` with bundled sample diff.
- Write unit tests with Catch2.

### Phase 3: Review Pipeline (C++)
- Implement `RepoDiffSystem` (git diff via `libgit2` or subprocess).
- Implement diff chunking for prompt budget management.
- Implement `CopilotRunnerSystem` (`copilot -p` subprocess wrapper).
- Implement record/replay mode for deterministic testing.
- Implement `PersonaReviewSystem` (persona loop, JSON validation, repair).
- Implement `SynthesisSystem` (dedupe, prioritize, unified markdown).
- Implement `reviewcat review` end-to-end.

### Phase 4: GitHub Integration
- Implement `GitHubOpsSystem` (fetch PR diff, post comment via `gh`).
- Implement `reviewcat pr` command.
- Implement watch mode daemon for continuous monitoring.

### Phase 5: Patch Automation
- Implement `PatchApplySystem` (generate patches, apply with safety checks).
- Implement `reviewcat fix` command.

### Phase 6: End-User UI (C++)
- Integrate Dear ImGui with SDL2 or GLFW backend.
- Implement dashboard, settings, stats, audit log, daemon controls.

### Phase 7: Polish & Distribution
- Produce single static binary (`reviewcat`).
- Add comprehensive error handling and logging (`spdlog`).
- Write end-user documentation.
- Set up CI/CD (GitHub Actions with CMake).

## 10. Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Language | **C++17/20** | Fast native binary; no runtime deps; cross-platform |
| Dev harness | **Bash scripts** | Simple, no build step needed, runs anywhere with Copilot CLI |
| Build system | **CMake** | Industry standard for C++ |
| UI framework | **Dear ImGui** | Lightweight, immediate-mode, easy to embed in C++ binary |
| Copilot invocation | **Subprocess** (`copilot -p`) | No SDK dependency; works from both bash and C++ |
| Agent communication | File-based artifacts | Simple, auditable, no IPC complexity |
| Daemon model | Bash loop (dev) / C++ daemon (runtime) | Dev harness needs no compilation; runtime is compiled |
| Config format | **TOML** | Human-readable, C++ parsers available |
| Test framework | **Catch2** | Header-only, widely used, good CMake support |
| JSON library | **nlohmann/json** | De facto standard for C++ JSON |
| Git library | **libgit2** | C library with C++ wrappers; no subprocess needed |

## 11. Inspiration & Prior Art

| Project | What We Borrow |
|---------|---------------|
| [Ralph](https://github.com/soderlind/ralph) | Heartbeat loop, PRD-driven task picking, progress tracking, permission profiles |
| [CEO Orchestration](https://github.com/ivfarias/ceo) | Agent profiles, index-driven discovery, workflow prescription, file-based coordination |
| [Copilot Swarm Orchestrator](https://github.com/moonrunnerkc/copilot-swarm-orchestrator) | Parallel wave execution, branch isolation, transcript verification |
| [Kodus AI](https://github.com/kodustech/kodus-ai) | Production code review agent patterns |

## 12. Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Copilot CLI quota limits | Record/replay mode for tests; caching per chunk/persona |
| Agent produces bad code | Build/test validation gate; max retry budget; human review fallback |
| Daemon crashes | Watchdog with auto-restart in bash; PID file; graceful state persistence |
| Scope creep in autonomous dev | Director enforces spec scope; refuse unscoped changes |
| Credential exposure | Never store tokens in code; redaction rules; `.gitignore` for config |
| C++ compile times | Precompiled headers; modular CMake targets; incremental builds |
| WSL-specific issues | Test on WSL Ubuntu; document WSL prerequisites |
