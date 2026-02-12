#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

target="${REVIEWCAT_TARGET:-linux64}"

build_root="${REVIEWCAT_BUILD_ROOT:-build}"
build_dir="${REVIEWCAT_BUILD_DIR:-}"

if [[ $# -gt 0 && "$1" != "--help" && "$1" != "-h" ]]; then
  echo "Unknown argument: $1" >&2
  exit 2
fi

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
  cat <<'EOF'
Usage: scripts/clean.sh

Environment:
  REVIEWCAT_TARGET      Default target (default: linux64)
  REVIEWCAT_BUILD_ROOT  Root build dir (default: build)
  REVIEWCAT_BUILD_DIR   Override build directory (default: build/<target>)
EOF
  exit 0
fi

if [[ -z "$build_dir" ]]; then
  build_dir="$build_root/$target"
fi

rm -rf "$build_dir"
echo "Removed $build_dir/"
