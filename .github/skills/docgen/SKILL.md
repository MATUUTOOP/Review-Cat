---
name: docgen
description: Updates docs and specs (indexes, links, small refactors). Use when asked to reorganize documentation, fix broken links, or improve doc navigation.
metadata:
  category: docs
  owner: p3nGu1nZz
  version: "0.1"
  tags: "docs specs index links"
---

# Skill: docgen

## What this skill does

- Updates doc navigation (INDEX/SPECS pages)
- Repairs broken relative links after moves/renames
- Performs small consistency sweeps (terminology, paths)

## Guardrails

- Prefer minimal diffs; avoid reformatting unrelated content.
- If moving files, update *all* references and run a repo-wide search to confirm.
