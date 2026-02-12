# Documentation Index

This repository uses **one** root `README.md`. Everything else lives under `docs/`.

ReviewCat has **two distinct documentation tracks**:

- **Dev harness** (how ReviewCat builds and improves itself)
- **Runtime app** (what end users run)

Cross-cutting overview:

- Architecture overview: [`docs/ARCHITECTURE.md`](ARCHITECTURE.md)

## Dev harness docs

Start here:

- [`docs/dev/INDEX.md`](dev/INDEX.md)

Key pages:

- Environment variables and secrets: [`docs/dev/ENVIRONMENT.md`](dev/ENVIRONMENT.md)
- Dev harness configuration: [`docs/dev/CONFIGURATION.md`](dev/CONFIGURATION.md)
- Containers + worktrees (execution model): [`docs/dev/CONTAINERS_AND_WORKTREES.md`](dev/CONTAINERS_AND_WORKTREES.md)

## Runtime app docs

Start here:

- [`docs/app/INDEX.md`](app/INDEX.md)

Key pages:

- Runtime CLI + artifacts: [`docs/app/USAGE.md`](app/USAGE.md)
- App configuration: [`docs/app/CONFIGURATION.md`](app/CONFIGURATION.md)

## Specs

Specs are split by concern:

- **Dev harness specs**: [`docs/specs/dev/`](specs/dev/) (agents + harness systems)
- **Runtime app specs**: [`docs/specs/app/`](specs/app/) (components/entities/systems)

Start at [`docs/specs/SPECS.md`](specs/SPECS.md).
