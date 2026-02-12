# Dev Harness Specs Index

This index groups specs by **dev harness** concern.

## Agents

- [`DirectorDevAgent`](agents/DirectorDevAgent.md)
- [`CodingAgent`](agents/CodingAgent.md)
- [`MemoryAgent`](agents/MemoryAgent.md)
- [`RoleAgents`](agents/RoleAgents.md)

## Systems (dev harness)

- [`WorktreeSystem`](systems/WorktreeSystem.md)
- [`AgentBusSystem`](systems/AgentBusSystem.md)
- [`MemorySyncSystem`](systems/MemorySyncSystem.md)
- [`OrchestrationFSMSystem`](systems/OrchestrationFSMSystem.md)
- [`ReleaseCycleSystem`](systems/ReleaseCycleSystem.md)
- [`SelfReviewSystem`](systems/SelfReviewSystem.md)
- [`CodingAgentSystem`](systems/CodingAgentSystem.md)
- [`SwarmVisualizerSystem`](systems/SwarmVisualizerSystem.md)

## Systems (shared)

Some systems are used in both dev and runtime contexts. Canonical location is under dev:

- [`GitHubOpsSystem`](systems/GitHubOpsSystem.md)
- [`RequestBudgetSystem`](systems/RequestBudgetSystem.md)
- [`AuditStoreSystem`](systems/AuditStoreSystem.md)

## Components (dev harness)

- [`StateFile`](components/StateFile.md)
- [`EngramDTO`](components/EngramDTO.md)
- [`EngramCatalogDTO`](components/EngramCatalogDTO.md)
- [`RepoScaffold`](components/RepoScaffold.md)
- [`SkillsLibrary`](components/SkillsLibrary.md)
- [`TestDirectory`](components/TestDirectory.md)

## Related docs

- Director workflow: [`DIRECTOR_DEV_WORKFLOW.md`](DIRECTOR_DEV_WORKFLOW.md)
- Containers + worktrees: [`CONTAINERS_AND_WORKTREES.md`](CONTAINERS_AND_WORKTREES.md)
- Dev harness configuration: [`CONFIGURATION.md`](CONFIGURATION.md)
