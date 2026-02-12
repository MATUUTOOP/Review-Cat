#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

cmd="dev"
target="${REVIEWCAT_TARGET:-linux64}"
config="Debug"

build_root="${REVIEWCAT_BUILD_ROOT:-build}"
build_dir="${REVIEWCAT_BUILD_DIR:-}"

generator=""
parallel=""

tests_mode="auto" # auto|on|off

cmake_extra_args=()
build_extra_args=()

usage() {
  cat <<'EOF'
Usage: scripts/build.sh [dev|app|tests] [options]

Commands:
  dev     Configure + build the repo for development (default)
  app     Build the reviewcat app target
  tests   Build the Catch2 test target(s)

Options:
  --target linux64|win64     Build target platform (default: linux64)
  --config Debug|Release     CMake build type (default: Debug)
  --generator <name>         CMake generator override (default: Ninja if available)
  --parallel <n>             Build parallelism (passed to cmake --build)
  --with-tests               Force REVIEWCAT_BUILD_TESTS=ON
  --no-tests                 Force REVIEWCAT_BUILD_TESTS=OFF
  --cmake-arg <arg>          Extra CMake configure arg (repeatable)
  --build-arg <arg>          Extra CMake build arg (repeatable)

Environment:
  REVIEWCAT_TARGET      Default --target (default: linux64)
  REVIEWCAT_BUILD_ROOT  Root build dir (default: build)
  REVIEWCAT_BUILD_DIR   Override build directory (default: build/<target>)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    dev|app|tests)
      cmd="$1"; shift 1 ;;
    --config)
      config="${2:-}"; shift 2 ;;
    --config=*)
      config="${1#*=}"; shift 1 ;;
    --target)
      target="${2:-}"; shift 2 ;;
    --target=*)
      target="${1#*=}"; shift 1 ;;
    --generator)
      generator="${2:-}"; shift 2 ;;
    --generator=*)
      generator="${1#*=}"; shift 1 ;;
    --parallel)
      parallel="${2:-}"; shift 2 ;;
    --parallel=*)
      parallel="${1#*=}"; shift 1 ;;
    --with-tests)
      tests_mode="on"; shift 1 ;;
    --no-tests)
      tests_mode="off"; shift 1 ;;
    --cmake-arg)
      cmake_extra_args+=("${2:-}"); shift 2 ;;
    --build-arg)
      build_extra_args+=("${2:-}"); shift 2 ;;
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

case "$target" in
  linux64|win64) ;;
  *)
    echo "Invalid --target: $target (expected linux64 or win64)" >&2
    exit 2
    ;;
esac

case "$cmd" in
  dev|app|tests) ;;
  *)
    echo "Invalid command: $cmd (expected dev, app, or tests)" >&2
    exit 2
    ;;
esac

if [[ -z "$build_dir" ]]; then
  build_dir="$build_root/$target"
fi

tests_flag="ON"
if [[ "$tests_mode" == "off" ]]; then
  tests_flag="OFF"
elif [[ "$tests_mode" == "auto" ]]; then
  if [[ "$cmd" == "app" ]]; then
    tests_flag="OFF"
  fi
fi

cmake_gen_args=()
if [[ -n "$generator" ]]; then
  cmake_gen_args+=("-G" "$generator")
elif command -v ninja >/dev/null 2>&1; then
  cmake_gen_args+=("-G" "Ninja")
fi

cmake_toolchain_args=()
if [[ "$target" == "win64" ]]; then
  toolchain_file="$repo_root/cmake/toolchains/win64-mingw.cmake"
  if [[ ! -f "$toolchain_file" ]]; then
    echo "Missing toolchain file: $toolchain_file" >&2
    exit 2
  fi
  cmake_toolchain_args+=("-DCMAKE_TOOLCHAIN_FILE=$toolchain_file")
fi

cmake -S . -B "$build_dir" \
  -DCMAKE_BUILD_TYPE="$config" \
  -DREVIEWCAT_BUILD_TESTS="$tests_flag" \
  "${cmake_gen_args[@]}" \
  "${cmake_toolchain_args[@]}" \
  "${cmake_extra_args[@]}"

build_cmd=(cmake --build "$build_dir" --config "$config")
if [[ -n "$parallel" ]]; then
  build_cmd+=(--parallel "$parallel")
else
  build_cmd+=(--parallel)
fi

case "$cmd" in
  dev)
    ;;
  app)
    build_cmd+=(--target reviewcat)
    ;;
  tests)
    build_cmd+=(--target reviewcat_tests)
    ;;
esac

build_cmd+=("${build_extra_args[@]}")
"${build_cmd[@]}"

echo "Build dir: $build_dir"
echo "Bin dir:   $build_dir/bin"
