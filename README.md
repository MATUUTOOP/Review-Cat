# ReviewCat

**Autonomous, self-improving code review daemon** — uses GitHub Copilot CLI
and the GitHub MCP Server to provide persona-based code review, unified
synthesis, automated fix implementation, and circular self-improvement for
any Git repository.

ReviewCat is also **self-building**: a development harness powered by Copilot
CLI agents autonomously develops, tests, and iterates on its own codebase
through a circular review → issue → fix → PR → merge → review loop that runs
indefinitely.

## Key Features

- **Persona-based review** — Security, performance, architecture, testing, and docs agents.
- **Unified synthesis** — Deduplicated, prioritized findings in markdown + JSON.
- **Coding agents** — Automated fix implementation from review findings via GitHub Issues and PRs.
- **Circular self-improvement** — ReviewCat reviews itself, creates issues, fixes them, merges, and repeats indefinitely.
- **GitHub MCP Server** — Agents use MCP tools for issues, PRs, comments, and labels.
- **Parallel worktrees** — Multiple agents work simultaneously in isolated git worktrees.
- **Audit trail** — Every Copilot CLI call recorded in a prompt ledger.
- **Daemon mode** — Continuous monitoring with configurable intervals.
- **Native UI** — Dear ImGui window for settings, stats, and control.
- **Self-building** — Director daemon (Agent 0) orchestrates development via heartbeat loop.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | C++17/20 |
| Build system | CMake |
| Dev harness | Bash shell scripts |
| UI | Dear ImGui (SDL2/GLFW) |
| Copilot integration | `copilot -p` subprocess |
| GitHub integration | GitHub MCP Server + `gh` CLI fallback |
| Git ops | libgit2 + `git worktree` |
| JSON | nlohmann/json |
| Config | TOML (toml++) |
| Testing | Catch2 |
| Package manager | vcpkg |

## Repository Structure

```
Review-Cat/
├── app/                    # The product (C++ binary)
│   ├── src/                # C++ source code
│   │   ├── core/           # Core library (components, entities, systems)
│   │   ├── cli/            # CLI frontend (main, arg parsing)
│   │   ├── daemon/         # Daemon / watch mode
│   │   ├── ui/             # UI window (Dear ImGui)
│   │   └── copilot/        # Copilot CLI subprocess bridge
│   ├── include/            # Public headers
│   ├── tests/              # Catch2 test suite
│   ├── config/             # Default configs, persona templates
│   └── CMakeLists.txt      # App build system
│
├── dev/                    # Development harness (bash scripts)
│   ├── agents/             # Role agent prompt files
│   ├── harness/            # Director daemon & cycle scripts
│   │   ├── director.sh     # Heartbeat daemon loop
│   │   ├── run-cycle.sh    # Single task cycle in worktree
│   │   ├── worktree.sh     # Worktree create/teardown helpers
│   │   ├── review-self.sh  # Self-review bootstrap
│   │   └── monitor-workers.sh  # Worker completion monitoring
│   ├── plans/              # PRD backlog (prd.json)
│   ├── scripts/            # Bootstrap and utility scripts
│   └── audits/             # Development audit bundles
│
├── docs/                   # Design docs & specifications
│   ├── specs/              # Component, entity, system, agent specs
│   ├── COPILOT_CLI_CHALLENGE_DESIGN.md
│   ├── DIRECTOR_DEV_WORKFLOW.md
│   ├── IMPLEMENTATION_CHECKLIST.md
│   └── PROMPT_COOKBOOK.md
│
├── scripts/                # Top-level build/test/clean scripts
├── PLAN.md                 # Comprehensive project plan (golden source)
└── TODO.md                 # Actionable task list
```

## Quick Start

```bash
# Prerequisites: CMake, C++17 compiler, Copilot CLI, gh CLI

# Clone
git clone https://github.com/p3nGu1nZz/Review-Cat.git
cd Review-Cat

# Build
./scripts/build.sh

# Run demo (no auth required)
./build/reviewcat demo

# Review local changes
./build/reviewcat review

# Review a PR
./build/reviewcat pr 42 --repo OWNER/REPO

# Start daemon mode (circular review → fix → merge → review)
./build/reviewcat watch --interval 60

# Open UI
./build/reviewcat ui
```

## Development (Self-Building)

The development harness runs autonomously via the Director daemon (Agent 0):

```bash
# Bootstrap dev environment (verify prereqs, configure GitHub MCP, create issues)
./dev/scripts/bootstrap.sh

# Start Director daemon (heartbeat loop — runs indefinitely)
./dev/harness/director.sh
```

The Director's heartbeat loop:

1. **Scan** — List open GitHub Issues labeled `agent-task` via GitHub MCP.
2. **Claim** — Add `agent-claimed` label to prevent duplicate work.
3. **Dispatch** — Create worktrees, spawn coding agents to implement fixes.
4. **Monitor** — Check worktree workers for completion.
5. **Validate** — Run `./scripts/build.sh && ./scripts/test.sh`.
6. **Merge** — Merge PRs, close linked issues, teardown worktrees.
7. **Self-review** — When idle, review own code and create new issues.
8. **Sleep** — Wait for next heartbeat interval, then repeat.

See [PLAN.md](PLAN.md) §5 for full heartbeat architecture.

## Documentation

| Document | Purpose |
|---------|---------|
| [PLAN.md](PLAN.md) | Comprehensive project plan (golden source of truth) |
| [TODO.md](TODO.md) | Actionable task list by phase |
| [Design Doc](docs/COPILOT_CLI_CHALLENGE_DESIGN.md) | Architecture, UX, integration design |
| [Director Workflow](docs/DIRECTOR_DEV_WORKFLOW.md) | DirectorDev coordination spec |
| [Implementation Checklist](docs/IMPLEMENTATION_CHECKLIST.md) | Step-by-step checklist |
| [Prompt Cookbook](docs/PROMPT_COOKBOOK.md) | Curated prompt patterns |
| [Specs](docs/specs/) | Component, entity, system, agent specifications |

## Specs

All specs live under `docs/specs/`:

- `components/` — Pure data structures (RunConfig, ReviewFinding, etc.)
- `entities/` — Factories and construction rules (AuditIdFactory, PromptFactory)
- `systems/` — Modules with logic and side-effects (RepoDiffSystem,
  CopilotRunnerSystem, PersonaReviewSystem, SynthesisSystem, CodingAgentSystem,
  GitHubOpsSystem, WorktreeSystem, SelfReviewSystem, etc.)
- `agents/` — Copilot CLI custom agents (DirectorDevAgent, RoleAgents, CodingAgent)

Development is spec-first: update or add a spec, then implement to match
acceptance criteria.

## License

See [LICENSE](LICENSE).
