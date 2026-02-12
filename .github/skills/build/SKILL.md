---
name: build
description: Builds this repository using CMake (via scripts/build.sh). Use when asked to build, compile, or troubleshoot build failures.
compatibility: Requires bash, cmake, and a C++ toolchain.
metadata:
  category: build-and-ci
  owner: p3nGu1nZz
  version: "0.1"
  tags: "build cmake compile"
---

# Skill: build

## What this skill does

Builds ReviewCat using the repo's canonical build script.

## How to use

- Default build (Debug): run `./scripts/build.sh`
- Release build: run `./scripts/build.sh --config Release`

## Outputs

- Build directory: `build/` (or `$REVIEWCAT_BUILD_DIR`)
- Binary: `build/reviewcat`

## Related

- `docs/specs/dev/components/RepoScaffold.md`