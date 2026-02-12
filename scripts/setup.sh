#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

install=0
run_gate=0

usage() {
  cat <<'EOF'
Usage: scripts/setup.sh [--install] [--run-gate]

Bootstraps the local dev environment for ReviewCat.

Default behavior (no flags):
- verify required tooling is present
- ensure scripts are executable
- validate basic Agent Skills file structure (light sanity checks)

Options:
  --install   Attempt to install missing deps on Debian/Ubuntu via apt (requires sudo).
  --run-gate  Run ./scripts/build.sh && ./scripts/test.sh --unit after setup.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install)
      install=1; shift 1 ;;
    --run-gate)
      run_gate=1; shift 1 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

need_cmd() {
  local cmd="$1"
  local hint="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing: $cmd" >&2
    echo "  Hint: $hint" >&2
    return 1
  fi
  return 0
}

apt_install() {
  if [[ "$install" -ne 1 ]]; then
    return 1
  fi
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get not found; cannot auto-install dependencies." >&2
    return 1
  fi
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo not found; cannot auto-install dependencies." >&2
    return 1
  fi

  echo "Installing dependencies via apt (requires sudo)..."
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    python3
}

missing=0

need_cmd git "Install git (required for worktrees and repo ops)." || missing=1
need_cmd cmake "Install CMake (e.g., apt-get install cmake)." || missing=1
need_cmd ctest "ctest is part of CMake; ensure CMake is installed." || missing=1
need_cmd bash "bash is required to run scripts." || missing=1

# Prefer c++ (what CMake will use); accept clang++ as alternative.
if ! command -v c++ >/dev/null 2>&1 && ! command -v clang++ >/dev/null 2>&1; then
  echo "Missing: C++ compiler (c++ or clang++)" >&2
  missing=1
fi

# Optional but nice.
if ! command -v ninja >/dev/null 2>&1; then
  echo "Optional: ninja not found (build will still work; slower generator may be used)." >&2
fi

if [[ "$missing" -ne 0 ]]; then
  echo "One or more required tools are missing." >&2
  if apt_install; then
    echo "Installed deps; re-run setup to verify." >&2
    exit 0
  fi
  echo "Re-run with --install on Debian/Ubuntu, or install the missing tools manually." >&2
  exit 1
fi

# Ensure scripts are executable.
chmod +x scripts/*.sh

# Light sanity checks for Agent Skills frontmatter.
if [[ -d .github/skills ]]; then
  bad=0
  while IFS= read -r -d '' f; do
    if [[ ! -s "$f" ]]; then
      echo "Empty SKILL.md: $f" >&2
      bad=1
      continue
    fi
    first="$(head -n 1 "$f" | tr -d '\r')"
    if [[ "$first" != '---' ]]; then
      echo "SKILL.md missing YAML frontmatter start ('---'): $f" >&2
      bad=1
      continue
    fi
  done < <(find .github/skills -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print0)

  if [[ "$bad" -ne 0 ]]; then
    echo "Skill sanity checks failed." >&2
    exit 1
  fi
fi

echo "Setup OK." 

if [[ "$run_gate" -eq 1 ]]; then
  ./scripts/build.sh
  ./scripts/test.sh --unit
fi
