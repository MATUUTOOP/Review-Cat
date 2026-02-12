# Skills library (`.github/skills/`)

ReviewCat uses the **Agent Skills** open standard.

- Each skill is a directory containing a `SKILL.md`.
- `SKILL.md` MUST include YAML frontmatter with `name` and `description`.
- The frontmatter `name` MUST match the skill directory name.

## Catalog

### Build & CI

- [`build`](./build/) — Build the repo via CMake (`scripts/build.sh`).
- [`test-runner`](./test-runner/) — Run tests by suite (`scripts/test.sh`).

### Docs

- [`docgen`](./docgen/) — Update docs/indexes and sanity-check links.

### Memory

- [`memory-query`](./memory-query/) — Query `MEMORY.md` and `memory/{st,lt}` engrams.

### Repo / Git

- [`worktree-manager`](./worktree-manager/) — Manage git worktrees for worker containers.
- [`release-manager`](./release-manager/) — Coordinate release branch + aggregate release PR.

### Authoring

- [`skill-template`](./skill-template/) — Template for creating new skills (not meant for activation).
