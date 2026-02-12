# win64-mingw.cmake
# Minimal MinGW-w64 toolchain file for cross-compiling on Linux.
#
# Prereqs (Debian/Ubuntu example):
#   sudo apt-get install mingw-w64

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(_triplet x86_64-w64-mingw32)

set(CMAKE_C_COMPILER   ${_triplet}-gcc)
set(CMAKE_CXX_COMPILER ${_triplet}-g++)

# Where to look for libraries/headers.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
