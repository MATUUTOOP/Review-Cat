# CLI frontend

## Overview

The CLI frontend is responsible for parsing arguments, printing user-facing output, and selecting which runtime mode to execute.

## Requirements

1. Must have a `--help` output that includes demo instructions.
2. Must default to dry-run behavior.
3. Must print a short, readable terminal summary at end of each run.

## Interfaces

Commands:

- `demo`
- `review`
- `pr`
- `fix`
- `watch`
- `dev director`

Common flags:

- `--config <path>`
- `--personas <list>`
- `--base <ref>` / `--head <ref>`
- `--include <glob>` / `--exclude <glob>`
- `--dry-run`

## Acceptance criteria

- Invalid arguments produce usage error.
- Successful run prints artifact path.

## Test cases

- Parse flags and subcommands.
- Ensure `demo` requires no external tools.

## Edge cases

- Running outside a git repo.

## Non-functional constraints

- Output should be friendly for copy/paste into a DEV submission.
