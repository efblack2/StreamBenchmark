cmake_minimum_required(VERSION 3.9)

project(streamMPI_sm C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Release)

include_directories("src/include")
find_package(MPI REQUIRED)
include_directories(${MPI_INCLUDE_PATH})
set (streamMPI_sm "src/streamMPI_sm.c")
add_executable(streamMPI_sm ${streamMPI_sm})
target_link_libraries(streamMPI_sm ${MPI_LIBRARIES})

