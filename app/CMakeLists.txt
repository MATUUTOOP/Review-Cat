add_executable(reviewcat
  src/cli/main.cpp
)

target_compile_features(reviewcat PRIVATE cxx_std_17)

reviewcat_target_warnings(reviewcat)

# --- Minimal "green gate" tests ---
add_test(NAME reviewcat_help COMMAND $<TARGET_FILE:reviewcat> --help)
set_tests_properties(reviewcat_help PROPERTIES LABELS "unit")

add_test(NAME reviewcat_version COMMAND $<TARGET_FILE:reviewcat> --version)
set_tests_properties(reviewcat_version PROPERTIES LABELS "unit")

if (REVIEWCAT_BUILD_TESTS)
  include(FetchContent)

  # Prefer a system-provided Catch2 if available; fall back to FetchContent.
  find_package(Catch2 3 QUIET)
  if (NOT Catch2_FOUND)
    FetchContent_Declare(
      Catch2
      GIT_REPOSITORY https://github.com/catchorg/Catch2.git
      GIT_TAG v3.5.4
    )
    FetchContent_MakeAvailable(Catch2)
  endif()

  add_executable(reviewcat_tests
    tests/test_sanity.cpp
  )

  target_compile_features(reviewcat_tests PRIVATE cxx_std_17)
  reviewcat_target_warnings(reviewcat_tests)

  target_link_libraries(reviewcat_tests PRIVATE Catch2::Catch2WithMain)

  include(Catch)
  catch_discover_tests(reviewcat_tests
    TEST_PREFIX "catch2."
    PROPERTIES LABELS "unit"
  )
endif()
