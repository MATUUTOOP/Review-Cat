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
│   ├── src/                # Application source code
│   ├── ui/                 # UI window (settings, stats, control)
│   ├── agents/             # Runtime review persona agents
│   ├── config/             # Default configs, persona templates
│   ├── scripts/            # Build, test, package scripts
│   └── tests/              # App test suite
│
├── dev/                    # The meta-tooling — what builds the product
│   ├── agents/             # Development role agents (Director, Implementer, QA, etc.)
│   ├── harness/            # Heartbeat daemon, orchestration scripts
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
├── PLAN.md                 # This file
├── TODO.md                 # Actionable task list
└── README.md               # Project overview and quick start
```

### 2.1. `app/` — The Product

This is the ReviewCat application that end users install and run. It contains:

- **CLI frontend** (`reviewcat` commands: `demo`, `review`, `pr`, `fix`, `watch`)
- **Daemon mode** — persistent background process that monitors a repo
- **UI window** — lightweight desktop window for settings, stats, and control
- **Runtime agents** — persona review agents powered by embedded Copilot CLI SDK
- **Audit system** — structured artifact output for every review run
- **GitHub integration** — create PRs, issues, comments via `gh` CLI

### 2.2. `dev/` — The Development Harness

This is the meta-tooling that builds ReviewCat autonomously. It contains:

- **Agent 0 (Director)** — the always-running orchestrator daemon
- **Role agents** — Architect, Implementer, QA, Docs, Security, Code-Review
- **Heartbeat system** — persistent loop that keeps the Director alive
- **Progress tracking** — PRD items, task graphs, completion status
- **Development audits** — prompt ledgers and agent outputs for every dev cycle

## 3. Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Language | **TypeScript** (Node.js) | Copilot CLI SDK is npm-native; rapid iteration; works on WSL/Linux |
| Runtime | **Node.js 20+** | Cross-platform, single runtime for CLI + daemon + UI |
| UI | **Electron** (minimal shell) | Simple desktop window; settings, stats, control panels |
| CLI | **Commander.js** | Standard Node.js CLI framework |
| Copilot SDK | **@github/copilot** (embedded) | Powers both dev agents and runtime review agents |
| Git ops | **simple-git** + **gh CLI** | Programmatic git + GitHub API operations |
| Config | **TOML** (`reviewcat.toml`) | Human-readable, easy to edit |
| Testing | **Vitest** | Fast, TypeScript-native test runner |
| Build | **tsup** or **esbuild** | Fast TypeScript bundling |
| Package | **npm** | Standard distribution |

## 4. Agent Architecture

### 4.1. Development Agents (in `dev/`)

These run during development to build ReviewCat itself:

| Agent | Role | Responsibilities |
|-------|------|-----------------|
| **Director (Agent 0)** | Orchestrator | Reads specs, decomposes work, assigns tasks, validates acceptance, runs heartbeat |
| **Architect** | Design reviewer | Reviews architecture changes, watches complexity, enforces module boundaries |
| **Implementer** | Code writer | Writes source code to match specs and acceptance criteria |
| **QA** | Test engineer | Writes tests, runs test suites, adds record/replay fixtures |
| **Docs** | Documentation | Maintains README, examples, prompt cookbook, specs |
| **Security** | Security auditor | Enforces safe defaults, redaction, permission policy |
| **Code-Review** | Reviewer | Reviews diffs, blocks low-signal changes, final quality gate |

### 4.2. Runtime Agents (in `app/`)

These run when end users use ReviewCat to review code:

| Agent | Persona | Focus Area |
|-------|---------|-----------|
| **Security** | Vulnerability hunter | Exploitability, unsafe defaults, data leaks |
| **Performance** | Optimizer | Algorithmic complexity, hot paths, allocations |
| **Architecture** | Structural analyst | Module boundaries, naming, dependency direction |
| **Testing** | Test coverage analyst | Missing tests, concrete test case proposals |
| **Docs** | Documentation reviewer | Missing usage docs, confusing behaviors |

### 4.3. Copilot CLI SDK Integration

The Copilot CLI SDK (`@github/copilot`) is embedded directly into the project:

- **Development agents** invoke the SDK to generate code, run reviews, and
  execute tasks during the autonomous build process.
- **Runtime agents** invoke the SDK to run persona reviews when end users
  trigger code review operations.
- **Record/replay mode** stubs SDK responses for deterministic testing.

## 5. Agent 0: The Director Daemon

### 5.1. Heartbeat System

Agent 0 runs as a persistent daemon process with a heartbeat loop:

```
┌─────────────────────────────────────────────┐
│              Director Daemon                │
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

**Heartbeat loop:**

1. **Wake** — Timer fires (configurable interval, default 60s).
2. **Check backlog** — Read `dev/plans/prd.json` and `dev/plans/progress.json`.
3. **Select next task** — Pick highest-priority incomplete item.
4. **Load spec** — Read the target spec from `docs/specs/`.
5. **Decompose** — Create sub-tasks and assign to role agents.
6. **Execute cycle** — Run role agents sequentially with checkpoints.
7. **Validate** — Run build + tests. If fail, retry or log error.
8. **Record** — Write development audit bundle to `dev/audits/`.
9. **Commit** — Commit changes with structured commit message.
10. **Sleep** — Wait for next heartbeat interval.

### 5.2. Guardrails

- **Dry-run default** — no git push, no GitHub mutations without explicit opt-in.
- **Scope lock** — Director refuses to modify files outside the spec's scope.
- **Retry budget** — Max 3 retries per sub-task before marking failed.
- **Dangerous command deny list** — `rm -rf`, `git push --force`, etc.
- **Watchdog** — If a cycle exceeds timeout, Director kills and logs.

### 5.3. Bootstrap Sequence

To cold-start the Director for the first time:

```bash
# 1. Install dependencies
cd Review-Cat && npm install

# 2. Bootstrap the dev harness
./dev/scripts/bootstrap.sh

# 3. Start the Director daemon
./dev/scripts/start-director.sh
```

The Director reads `dev/plans/prd.json` for its initial work items and begins
executing cycles autonomously.

## 6. End-User UI

### 6.1. UI Window

A minimal Electron window provides:

- **Dashboard** — Active review status, recent findings, daemon health.
- **Settings** — Copilot credentials, GitHub access token, target repo, persona
  selection, review interval, notification preferences.
- **Stats** — Review counts, finding trends, persona breakdown, agent uptime.
- **Agent Personas** — Enable/disable personas, adjust severity thresholds.
- **Audit Log** — Browse past review runs and their artifacts.
- **Controls** — Start/stop daemon, trigger manual review, open audit directory.

### 6.2. Settings Screen

End users configure:

| Setting | Description |
|---------|------------|
| Copilot credentials | Authentication for Copilot CLI SDK |
| GitHub access token | PAT for creating PRs, issues, comments |
| Target repository | `OWNER/REPO` to monitor |
| Base branch | Default branch for diff comparison |
| Review interval | How often the daemon checks for changes (seconds) |
| Personas enabled | Which review personas to run |
| Auto-comment | Whether to post unified review as PR comment |
| Auto-fix | Whether to generate and apply patches |
| Redaction rules | Glob patterns for sensitive files to exclude |

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

1. **RepoDiffSystem** — Collect diffs, file lists, context windows.
2. **PersonaReviewSystem** — Run persona agents via Copilot CLI SDK.
3. **SynthesisSystem** — Deduplicate, prioritize, unify findings.
4. **AuditStoreSystem** — Write artifacts to disk, update index.
5. **GitHubOpsSystem** — Post comments, create issues/PRs (opt-in).
6. **PatchApplySystem** — Generate and apply safe patches (opt-in).

## 8. Development Workflow

### 8.1. Spec-First Development

All development follows the spec-first pattern:

1. Write or update a spec in `docs/specs/`.
2. Director reads the spec and extracts requirements + acceptance criteria.
3. Director assigns sub-tasks to role agents.
4. Agents implement, test, and document.
5. Director validates against acceptance criteria.
6. Director commits and records audit.

### 8.2. Development Loop (Ralph-Inspired)

The Director uses a loop pattern inspired by the
[Ralph Wiggum technique](https://www.humanlayer.dev/blog/brief-history-of-ralph):

1. **Read** — Load PRD and progress state.
2. **Pick** — Choose highest-priority incomplete item.
3. **Implement** — Delegate to role agents.
4. **Verify** — Run build + tests.
5. **Update** — Mark item complete, log progress.
6. **Commit** — Structured commit with audit trail.
7. **Repeat** — Until all items pass or budget exhausted.

### 8.3. Agent Orchestration (CEO-Inspired)

Drawing from the [CEO Orchestration System](https://github.com/ivfarias/ceo):

- Agent profiles are defined as markdown files in `.github/agents/`.
- The Director (Agent 0) acts as the CEO: it doesn't execute work directly but
  prescribes workflows and delegates to specialist agents.
- Agents communicate via file-based artifacts (specs, code, test results).

### 8.4. Parallel Execution (Swarm-Inspired)

Drawing from [Copilot Swarm Orchestrator](https://github.com/moonrunnerkc/copilot-swarm-orchestrator):

- Independent tasks can run in parallel on isolated git branches.
- Each agent's work is verified by parsing transcripts/outputs.
- Verified branches merge back to main.
- A wave scheduler groups independent tasks for parallel execution.

## 9. Phased Implementation Plan

### Phase 0: Repository Bootstrap & Dev Harness
- Create `app/` and `dev/` directory structure.
- Set up TypeScript project with build/test scripts.
- Install Copilot CLI SDK.
- Create Agent 0 heartbeat daemon skeleton.
- Define agent profiles in `.github/agents/`.
- Create `dev/plans/prd.json` initial backlog.

### Phase 1: Director Agent (Agent 0)
- Implement heartbeat loop with configurable interval.
- Implement spec reader (parse markdown specs into structured data).
- Implement task decomposition (spec → sub-tasks → role assignments).
- Implement sequential agent execution with checkpoints.
- Implement build/test validation runner.
- Implement development audit recording.
- Implement progress tracking (`dev/plans/progress.json`).

### Phase 2: Core App Skeleton
- Implement CLI frontend with command stubs.
- Implement `RunConfig` loading (TOML + CLI overrides).
- Implement `AuditIdFactory` and `AuditStoreSystem`.
- Implement prompt ledger (`PromptRecord`, `PromptFactory`).
- Implement `reviewcat demo` with bundled sample diff.

### Phase 3: Review Pipeline
- Implement `RepoDiffSystem` (git diff collection, filtering).
- Implement `CopilotRunnerSystem` (Copilot CLI SDK invocation, record/replay).
- Implement `PersonaReviewSystem` (persona loop, JSON validation, repair).
- Implement `SynthesisSystem` (dedupe, prioritize, unified markdown).
- Implement `reviewcat review` end-to-end.

### Phase 4: GitHub Integration
- Implement `GitHubOpsSystem` (fetch PR diff, post comment, create issue).
- Implement `reviewcat pr` command.
- Implement watch mode daemon for continuous monitoring.

### Phase 5: Patch Automation
- Implement `PatchApplySystem` (generate patches, apply with safety checks).
- Implement `reviewcat fix` command.
- Implement fix branch creation and PR opening.

### Phase 6: End-User UI
- Set up Electron shell with IPC to daemon.
- Implement dashboard view (status, recent findings).
- Implement settings screen (credentials, repo, personas).
- Implement stats view (charts, trends).
- Implement audit log browser.
- Implement daemon controls (start/stop, manual trigger).

### Phase 7: Polish & Distribution
- Package as npm installable.
- Add comprehensive error handling and logging.
- Add onboarding wizard for first-time setup.
- Write end-user documentation.
- Create demo recording and sample outputs.

## 10. Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Language | TypeScript | Copilot SDK is npm-native; unified stack for CLI + daemon + UI |
| UI framework | Electron | Cross-platform desktop window; minimal footprint |
| Agent communication | File-based artifacts | Simple, auditable, no IPC complexity |
| Daemon model | Node.js long-running process | Single runtime, no system service dependency |
| Config format | TOML | Human-readable, well-supported |
| Test runner | Vitest | Fast, TypeScript ESM-native |
| Dev loop model | Ralph Wiggum + CEO hybrid | Proven patterns from community projects |

## 11. Inspiration & Prior Art

| Project | What We Borrow |
|---------|---------------|
| [Ralph](https://github.com/soderlind/ralph) | Heartbeat loop, PRD-driven task picking, progress tracking, permission profiles |
| [CEO Orchestration](https://github.com/ivfarias/ceo) | Agent profiles, index-driven discovery, workflow prescription, file-based coordination |
| [Copilot Swarm Orchestrator](https://github.com/moonrunnerkc/copilot-swarm-orchestrator) | Parallel wave execution, branch isolation, transcript verification, agent specialization |
| [TypedAI](https://github.com/TrafficGuard/typedai) | TypeScript agent framework patterns |
| [Kodus AI](https://github.com/kodustech/kodus-ai) | Production code review agent patterns |

## 12. Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Copilot CLI SDK quota limits | Record/replay mode for tests; caching per chunk/persona |
| Agent produces bad code | Build/test validation gate; max retry budget; human review fallback |
| Daemon crashes | Watchdog with auto-restart; graceful state persistence |
| Scope creep in autonomous dev | Director enforces spec scope; refuse unscoped changes |
| Credential exposure | Never store tokens in code; redaction rules; config exclusion |
| WSL-specific issues | Test on WSL Ubuntu; document WSL prerequisites |
