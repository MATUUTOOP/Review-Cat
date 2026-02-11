# ReviewCat design set

This directory contains the design and specification documents for the ReviewCat hackathon project.

## Files

- `COPILOT_CLI_CHALLENGE_DESIGN.md`
  - Primary design doc (goals, UX, architecture, implementation plan).

- `IMPLEMENTATION_CHECKLIST.md`
  - A step-by-step checklist intended to prevent missed work during implementation.

- `DIRECTOR_DEV_WORKFLOW.md`
  - Detailed spec for the recursive DirectorDev workflow that uses Copilot CLI role agents to coordinate development.

- `PROMPT_COOKBOOK.md`
  - Curated prompt patterns for personas, synthesis, patch planning, and DirectorDev.

## Specs

All specs live under `specs/`:

- `specs/components/` pure data structures
- `specs/entities/` factories and construction rules
- `specs/systems/` modules that contain logic and side-effects
- `specs/agents/` Copilot CLI custom agents and role workflows

The intent is spec-first: update or add a spec, then implement to match acceptance criteria.
