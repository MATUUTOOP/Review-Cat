# RunConfig component

## Overview

`RunConfig` represents user configuration and policy defaults for ReviewCat.

## Requirements

1. Must support CLI overrides.
2. Must define policy for Copilot tool permissions.
3. Must define which personas are enabled.
4. Must define redaction rules.

## Interfaces

- Config file path (recommendation): `config/reviewcat.toml` or `reviewcat.toml`.
- CLI flags override config values.

Fields:

- `base_ref` default
- `personas` list
- `copilot`:
  - `model` (optional)
  - `allow_tools` allowlist
  - `deny_tools` denylist
- `github`:
  - `enabled` bool
  - `repo` default owner/repo
- `redaction`:
  - `exclude_globs`
  - `mask_patterns`

## Acceptance criteria

- Running with no config uses safe defaults.
- CLI flags override config.
- A config can disable all GitHub operations.

## Test cases

- Parse valid config.
- Reject invalid persona names.
- Override base_ref via CLI.

## Edge cases

- Missing config file.
- Partial config.

## Non-functional constraints

- Do not store secrets in config.
