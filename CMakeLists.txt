cmake_minimum_required(VERSION 3.20)

project(reviewcat LANGUAGES CXX)

include("${CMAKE_SOURCE_DIR}/ReviewCatBase.cmake")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

enable_testing()

add_subdirectory(app)
