# ReviewCatBase.cmake
# Shared CMake defaults for ReviewCat.

include_guard(GLOBAL)

# Keep build outputs stable across targets and generators.
# Expected layout: build/<target>/bin
set(_reviewcat_bin_dir "${CMAKE_BINARY_DIR}/bin")
set(_reviewcat_lib_dir "${CMAKE_BINARY_DIR}/lib")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${_reviewcat_bin_dir}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${_reviewcat_bin_dir}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${_reviewcat_lib_dir}")

foreach(_cfg Debug Release RelWithDebInfo MinSizeRel)
  string(TOUPPER "${_cfg}" _cfg_u)
  set("CMAKE_RUNTIME_OUTPUT_DIRECTORY_${_cfg_u}" "${_reviewcat_bin_dir}")
  set("CMAKE_LIBRARY_OUTPUT_DIRECTORY_${_cfg_u}" "${_reviewcat_bin_dir}")
  set("CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${_cfg_u}" "${_reviewcat_lib_dir}")
endforeach()

# Keep build output tidy in IDEs.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Handy for IDE tooling and clangd.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(REVIEWCAT_BUILD_TESTS "Build ReviewCat tests (Catch2)" ON)

function(reviewcat_target_warnings target)
  if (MSVC)
    target_compile_options(${target} PRIVATE /W4 /permissive-)
  else()
    target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic)
  endif()
endfunction()
