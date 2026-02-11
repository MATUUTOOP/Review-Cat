# Role agents (custom Copilot CLI agents)

## Overview

ReviewCat uses a set of custom Copilot CLI agents to represent development roles.

These agents are used by the DirectorDev workflow.

## Requirements

1. Each role agent must have a clear mandate and refusal rules.
2. Agents must be runnable via Copilot CLI by name.
3. Agents must follow repository instructions and testing requirements.

## Interfaces

Repository-level agent profiles live in:

- `.github/agents/<agent_name>.md`

Recommended agents:

- `director-dev` (orchestrator)
- `architect`
- `implementer`
- `qa`
- `docs`
- `security`
- `code-review`

Each agent profile should specify:

- mission
- output format
- allowed tools guidance
- testing requirements

## Acceptance criteria

- DirectorDev can run a full cycle using these agents.
- Agents do not produce scope creep without Director approval.

## Test cases

- Not applicable (agent definitions are behavioral), but the DirectorDev replay mode should cover orchestration.

## Edge cases

- Conflicting guidance from different agents.

## Non-functional constraints

- Safety: agents must not recommend storing secrets.
- Determinism: agent output should be structured where possible.
