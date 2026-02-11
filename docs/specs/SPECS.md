# ReviewCat Specifications

Specs are organized by category.

- `components/` — pure data structures (RunConfig, ReviewFinding, etc.)
  - Memory DTOs: `EngramDTO`, `EngramCatalogDTO`
- `entities/` — construction and factory rules (AuditIdFactory, PromptFactory)
- `systems/` — modules with logic and side-effects:
  - `RepoDiffSystem` — diff collection and chunking
  - `CopilotRunnerSystem` — Copilot CLI subprocess with MCP support
  - `PersonaReviewSystem` — persona agent loop and JSON validation
  - `SynthesisSystem` — finding dedup, prioritization, unified output
  - `CodingAgentSystem` — dispatch coding agents to fix findings
  - `PatchApplySystem` — safe patch generation and application
  - `GitHubOpsSystem` — GitHub MCP Server + `gh` CLI integration
  - `AuditStoreSystem` — artifact persistence and indexing
  - `DirectorRuntimeSystem` — end-to-end review/fix pipeline orchestration
  - `WorktreeSystem` — git worktree lifecycle for parallel agents
  - `SelfReviewSystem` — circular self-review and issue creation
  - `LoggingSystem` — structured logging (spdlog + bash) for all components
  - `ToolUISystem` — SDL3-based minimal Tool UI: primitives + bitmap font + status bars
  - `SwarmVisualizerSystem` — SDL3-based operator UI for live swarm graph + controls
  - `MemorySyncSystem` — bounded event-buffer memory + oldest-first compaction into engrams under `/memory/`
  - `RequestBudgetSystem` — swarm-level pacing/backpressure for GitHub + model calls (rate limits, cooldowns)
  - `OrchestrationFSMSystem` — Director/worker finite state machines for dev harness behavior
  - `ReleaseCycleSystem` — release batching via `feature/release-*`, merge-agent finalization, version broadcast + safe upgrades
- `agents/` — Copilot CLI agent definitions and DirectorDev orchestration:
  - `DirectorDevAgent` — heartbeat daemon, worktree management, self-improvement
  - `RoleAgents` — agent roster (implementer, coder, QA, docs, security, etc.)
  - `CodingAgent` — issue→fix→PR workflow for coding agents
  - `MemoryAgent` — extracts/compacts older swarm events into versioned engram DTOs

Each spec follows `specs/_template.md`.
