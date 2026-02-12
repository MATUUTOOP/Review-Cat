#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

config="Debug"
build_dir="${REVIEWCAT_BUILD_DIR:-build}"

usage() {
  cat <<'EOF'
Usage: scripts/build.sh [--config Debug|Release]

Environment:
  REVIEWCAT_BUILD_DIR  Override build directory (default: build)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      config="${2:-}"; shift 2 ;;
    --config=*)
      config="${1#*=}"; shift 1 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$config" != "Debug" && "$config" != "Release" ]]; then
  echo "Invalid --config: $config (expected Debug or Release)" >&2
  exit 2
fi

cmake_gen_args=()
if command -v ninja >/dev/null 2>&1; then
  cmake_gen_args+=("-G" "Ninja")
fi

cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="$config" "${cmake_gen_args[@]}"
cmake --build "$build_dir" --config "$config" --parallel
