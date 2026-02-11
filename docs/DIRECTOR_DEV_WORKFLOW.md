# DirectorDev Workflow (Self-Improving Development Coordination)

This document specifies how the ReviewCat project builds and improves itself
using GitHub Copilot CLI agents, the GitHub MCP Server, parallel git worktrees,
and a Director daemon (Agent 0) that orchestrates the circular self-improvement
loop.

> **See also:** [PLAN.md](../PLAN.md) §5 for heartbeat architecture,
> [TODO.md](../TODO.md) Phase 0–1 for implementation tasks, and
> [COPILOT_CLI_CHALLENGE_DESIGN.md](COPILOT_CLI_CHALLENGE_DESIGN.md) for full
> design context.

The key intent is not full autonomy. The intent is:

- consistent decomposition
- explicit acceptance criteria
- repeatable build/test loops
- recorded evidence of Copilot CLI usage
- autonomous forward progress with human oversight
- circular self-improvement via GitHub Issues and PRs

## Roles

DirectorDev coordinates these roles:

- **Director**: decomposes work, enforces scope, merges outputs, validates acceptance.
- **Architect**: reviews architecture changes, watches complexity.
- **Implementer**: writes code for spec-driven work.
- **Coder**: implements fixes for GitHub Issues (review findings), creates PRs.
- **QA**: writes tests and adds record/replay fixtures.
- **Docs**: maintains README, examples, prompt cookbook.
- **Security**: enforces safe defaults, redaction, permission policy.
- **Code-review**: reviews diffs and blocks low-signal changes.

In Copilot CLI, these roles are expressed as custom agents:

- Agent profiles live in `.github/agents/` (Copilot CLI repo-level agents).
- Role-specific prompt files live in `dev/agents/` (e.g., `architect.md`,
  `implementer.md`, `coder.md`, `qa.md`, `docs.md`, `security.md`,
  `code-review.md`).
- All agents are invoked via `copilot -p @dev/agents/<role>.md "..."`.
- Agents use the **GitHub MCP Server** for issue/PR operations when configured
  with `--mcp-config github-mcp.json`.

All development tooling is **bash shell scripts** under `dev/`.
No C++ compilation is required for the dev harness to operate.

## Inputs

- A target spec file in `docs/specs/`.
- Current repository state.
- PRD backlog (`dev/plans/prd.json`) with task items and status.
- Open GitHub Issues labeled `agent-task` (via GitHub MCP Server).
- Optional constraints:
  - time budget
  - risk tolerance (dry-run vs automation)
  - scope lock (files in scope for the target spec)

## Outputs

- Code changes implementing the spec or fixing the issue.
- Tests proving acceptance criteria.
- Updated docs.
- GitHub PRs linking source issues (`Closes #N`).
- GitHub Issue status updates (labels, comments).
- A development audit bundle under `dev/audits/<audit_id>/`:
  - `ledger/` — prompt/response pairs per agent
  - `build.log` — build output
  - `test.log` — test output
  - `diff.patch` — before/after diff
  - `summary.md` — Director's completion note

Audit bundles are indexed in `dev/audits/index.json`.

## Orchestration Algorithm

The Director runs as a **bash heartbeat daemon** (`dev/harness/director.sh`).
See [PLAN.md](../PLAN.md) §5 for the full heartbeat loop pseudocode.

### Per-Heartbeat Algorithm

1. **Scan GitHub** — List open issues labeled `agent-task` via GitHub MCP.
2. **Check PRD** — Read `dev/plans/prd.json` for spec-driven work.
3. **Check capacity** — Count active worktrees vs `MAX_WORKERS`.
4. **Claim issues** — For each unclaimed issue within capacity, add
   `agent-claimed` label via GitHub MCP.
5. **Dispatch workers** — For each claimed issue:
   - Create worktree via `dev/harness/worktree.sh create`.
   - Spawn `dev/harness/run-cycle.sh <issue> <branch>` in background.
6. **Monitor workers** — Via `dev/harness/monitor-workers.sh`:
   - Check completed worktrees.
   - Validate build/test in completed worktrees.
   - Agent creates PR via GitHub MCP.
   - Code-review agent reviews PR.
   - On pass: merge PR, close issue, teardown worktree.
   - On fail: retry (max 3), label `agent-blocked`.
7. **Self-review** — When idle (no issues, no PRD tasks):
   - Run `dev/harness/review-self.sh`.
   - Create new GitHub Issues for critical/high findings.
8. **Sleep** — Wait for configurable interval (default: 60s).

### Per-Task Algorithm (run-cycle.sh)

1. **Read issue** — Get issue details via GitHub MCP.
2. **Load spec** — If issue links a spec, load from `docs/specs/`.
3. **Invoke agents** — Run role agents sequentially in worktree:
   - Implementer/Coder: write code.
   - QA: write tests.
   - Docs: update documentation.
   - Security: review for vulnerabilities.
   - Code-review: review the diff.
4. **Validate** — `./scripts/build.sh && ./scripts/test.sh`.
5. **Create PR** — Via GitHub MCP with `Closes #<issue>`.
6. **Record audit** — Bundle all artifacts.

## Parallel Execution via Worktrees

Multiple agents work simultaneously in isolated git worktrees:

```
~/source/repos/
├── Review-Cat/                    # Main worktree (Director runs here)
├── Review-Cat-agent-42-1707600000/ # Worker 1 (implementing issue #42)
├── Review-Cat-agent-57-1707600060/ # Worker 2 (implementing issue #57)
└── Review-Cat-agent-63-1707600120/ # Worker 3 (implementing issue #63)
```

- Each worktree has its own branch, build directory, and test artifacts.
- Director manages up to `MAX_WORKERS` concurrent worktrees.
- Communication between agents is via GitHub Issue/PR comments, not files.
- Worktrees are torn down after PRs are merged.

## Inter-Agent Communication via GitHub

Agents communicate through GitHub's native features:

| Mechanism | Purpose | Example |
|-----------|---------|---------|
| **Issues** | Work items and findings | Review agent creates issue for a bug |
| **Issue comments** | Discussion and clarification | Architect comments on complexity |
| **PRs** | Code implementations | Coder agent creates PR fixing issue |
| **PR comments** | Review feedback | Code-review agent comments on PR |
| **Labels** | Categorization and routing | `agent-task`, `security`, `in-progress` |
| **Linked issues** | Traceability | PR description says "Closes #42" |

## Self-Review Loop

The core innovation: ReviewCat reviews itself, generates issues, fixes them,
and repeats indefinitely:

```
Review own code → Create GitHub Issues → Coding agent fixes →
Create PRs → Merge PRs → Review again → ...
```

This loop runs automatically when the Director has no other work. It enables
ReviewCat to bootstrap from minimal hardcoded scripts and progressively develop
itself into a full product.

## Coding Agent Workflow

When a review finding is promoted to a GitHub Issue, the Coder agent:

1. **Reads the issue** via GitHub MCP.
2. **Creates a branch** — `fix/<issue>-<description>`.
3. **Works in a worktree** — isolated environment.
4. **Implements the fix** — C++17/20 code following project conventions.
5. **Writes tests** — Catch2 test cases validating the fix.
6. **Runs build + test** — validates everything compiles and passes.
7. **Creates a PR** — via GitHub MCP, `Closes #<issue>`.
8. **Requests review** — adds `agent-review` label.

## Bootstrap Sequence

To cold-start the Director for the first time:

```bash
cd Review-Cat
./dev/scripts/bootstrap.sh    # Verify prereqs, configure MCP, create issues
./dev/harness/director.sh     # Start the Director daemon (loops indefinitely)
```

## Guardrails

- **Dry-run is default** — no `git push`, no GitHub mutations.
- **Scope lock** — Director refuses to modify files outside the spec's scope.
- **Retry budget** — Max 3 retries per sub-task before marking failed.
- **Dangerous command deny list** — `rm -rf /`, `git push --force`, etc.
- **Watchdog timeout** — Kill subprocess if a cycle exceeds time limit.
- **Permission profiles** — Copilot CLI `--allow-tools` / `--deny-tools` flags.
- **Worktree isolation** — Agents cannot modify the main worktree directly.
- **PR-gated merges** — All changes go through PRs, never direct main commits.
- **Label-based claiming** — Agents claim issues before starting work to avoid
  duplicate effort across parallel workers.
- **Severity threshold** — Auto-review only creates issues for critical/high findings.
- **Deduplication** — Self-review checks for existing open issues to prevent flooding.
- **PID file** — Single-instance enforcement for the Director daemon.

## Recursive and Circular Behavior

DirectorDev is recursive in the sense that:

- If a spec requires new subsystems, DirectorDev creates additional specs first.
- Each new spec becomes a new loop iteration.

DirectorDev is circular in the sense that:

- Self-review generates issues → coding agents fix them → PRs merge →
  self-review runs again on the updated code.
- This loop continues indefinitely while the daemon is active.

This keeps work modular and avoids monolithic changes, while enabling continuous
self-improvement of the ReviewCat codebase.

## How to Demonstrate

- Run one small DirectorDev cycle:
  ```bash
  ./dev/harness/director.sh  # or run a single cycle manually
  ```
- Show:
  - the spec file or GitHub Issue being implemented
  - the worktree created for the work
  - the resulting code change (`git diff`)
  - the test run (`./scripts/test.sh`)
  - the PR created via GitHub MCP
  - the prompt ledger (`dev/audits/<bundle>/ledger/`)

The prompt ledger is the proof that Copilot CLI was used meaningfully,
not just incidentally.
