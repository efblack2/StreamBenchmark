cmake_minimum_required(VERSION 3.9)

project(streamOpenMP C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Release)

set (streamOpenMP "src/streamOpenMP.c")
find_package(OpenMP REQUIRED)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
add_executable(streamOpenMP ${streamOpenMP})

