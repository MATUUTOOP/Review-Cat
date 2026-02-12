# scripts/

Repository scripts used by the **green build/test gate**.

- `build.sh` — configure + build the repo (idempotent)
- `test.sh` — run tests by suite (`--unit/--integration/--bench/--all`)
- `clean.sh` — remove build output

Build outputs are stored under `build/<target>/bin` (for example `build/linux64/bin/reviewcat`).

See `docs/specs/dev/components/RepoScaffold.md` for contract details.