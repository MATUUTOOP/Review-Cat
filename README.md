# ReviewCat

**Autonomous AI-powered code review daemon** — uses GitHub Copilot CLI to
provide persona-based code review, unified synthesis, and optional patch
automation for any Git repository.

ReviewCat is also **self-building**: a development harness powered by Copilot
CLI autonomously develops, tests, and iterates on its own codebase.

## Key Features

- **Persona-based review** — Security, performance, architecture, testing, and docs agents.
- **Unified synthesis** — Deduplicated, prioritized findings in markdown + JSON.
- **Audit trail** — Every Copilot CLI call recorded in a prompt ledger.
- **GitHub integration** — PR comments, issues, and patches via `gh` CLI.
- **Daemon mode** — Continuous monitoring with configurable intervals.
- **Native UI** — Dear ImGui window for settings, stats, and control.
- **Self-building** — Director daemon (Agent 0) that orchestrates development.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | C++17/20 |
| Build system | CMake |
| Dev harness | Bash shell scripts |
| UI | Dear ImGui (SDL2/GLFW) |
| Copilot integration | `copilot -p` subprocess |
| JSON | nlohmann/json |
| Config | TOML (toml++) |
| Testing | Catch2 |
| Git | libgit2 + `gh` CLI |

## Repository Structure

```
Review-Cat/
├── app/                    # The product (C++ binary)
│   ├── src/                # C++ source code
│   ├── include/            # Public headers
│   ├── tests/              # Catch2 test suite
│   ├── config/             # Default configs, persona templates
│   └── CMakeLists.txt      # App build system
│
├── dev/                    # Development harness (bash scripts)
│   ├── agents/             # Role agent prompt files
│   ├── harness/            # Director daemon & cycle scripts
│   ├── plans/              # PRD backlog (prd.json)
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
├── PLAN.md                 # Comprehensive project plan
└── TODO.md                 # Actionable task list
```

## Quick Start

```bash
# Prerequisites: CMake, C++17 compiler, Copilot CLI, gh CLI

# Clone
git clone https://github.com/<owner>/Review-Cat.git
cd Review-Cat

# Build
./scripts/build.sh

# Run demo (no auth required)
./build/reviewcat demo

# Review local changes
./build/reviewcat review

# Review a PR
./build/reviewcat pr 42 --repo OWNER/REPO

# Start daemon mode
./build/reviewcat watch --interval 60

# Open UI
./build/reviewcat ui
```

## Development (Self-Building)

The development harness runs autonomously via the Director daemon:

```bash
# Bootstrap dev environment
./dev/scripts/bootstrap.sh

# Start Director daemon (Agent 0)
./dev/harness/director.sh
```

The Director reads `dev/plans/prd.json`, delegates to Copilot CLI role agents,
validates via build + test, and commits. See [PLAN.md](PLAN.md) §5 for details.

## Documentation

| Document | Purpose |
|---------|---------|
| [PLAN.md](PLAN.md) | Comprehensive project plan (golden source of truth) |
| [TODO.md](TODO.md) | Actionable task list by phase |
| [Design Doc](docs/COPILOT_CLI_CHALLENGE_DESIGN.md) | Architecture, UX, integration design |
| [Director Workflow](docs/DIRECTOR_DEV_WORKFLOW.md) | DirectorDev recursive development spec |
| [Implementation Checklist](docs/IMPLEMENTATION_CHECKLIST.md) | Step-by-step checklist |
| [Prompt Cookbook](docs/PROMPT_COOKBOOK.md) | Curated prompt patterns |
| [Specs](docs/specs/) | Component, entity, system, agent specifications |

## Specs

All specs live under `docs/specs/`:

- `docs/specs/components/` — Pure data structures
- `docs/specs/entities/` — Factories and construction rules
- `docs/specs/systems/` — Modules with logic and side-effects
- `docs/specs/agents/` — Copilot CLI custom agents and role workflows

Development is spec-first: update or add a spec, then implement to match
acceptance criteria.

## License

See [LICENSE](LICENSE).
