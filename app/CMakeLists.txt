add_executable(reviewcat
  src/cli/main.cpp
)

# Keep the binary at a predictable location for scripts and CI.
set_target_properties(reviewcat PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)

target_compile_features(reviewcat PRIVATE cxx_std_17)

if (MSVC)
  target_compile_options(reviewcat PRIVATE /W4)
else()
  target_compile_options(reviewcat PRIVATE -Wall -Wextra -Wpedantic)
endif()

# --- Minimal "green gate" tests ---
add_test(NAME reviewcat_help COMMAND reviewcat --help)
set_tests_properties(reviewcat_help PROPERTIES LABELS "unit")

add_test(NAME reviewcat_version COMMAND reviewcat --version)
set_tests_properties(reviewcat_version PROPERTIES LABELS "unit")
