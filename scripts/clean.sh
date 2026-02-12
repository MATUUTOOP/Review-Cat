#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

build_dir="${REVIEWCAT_BUILD_DIR:-build}"

if [[ $# -gt 0 && "$1" != "--help" && "$1" != "-h" ]]; then
  echo "Unknown argument: $1" >&2
  exit 2
fi

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
  cat <<'EOF'
Usage: scripts/clean.sh

Environment:
  REVIEWCAT_BUILD_DIR  Override build directory (default: build)
EOF
  exit 0
fi

rm -rf "$build_dir"
echo "Removed $build_dir/"
