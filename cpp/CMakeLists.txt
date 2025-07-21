cmake_minimum_required(VERSION 3.15)

project(BlackjackTrainer
    VERSION 1.0.0
    DESCRIPTION "Blackjack Basic Strategy Trainer"
    LANGUAGES CXX)

# Set C++17 standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set compiler flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic -Werror")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic")
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -DNDEBUG")
endif()

# Include directories
include_directories(include)

# Collect source files
file(GLOB_RECURSE SOURCES "src/*.cpp")
list(REMOVE_ITEM SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")

# Create library for core functionality
add_library(blackjack_core STATIC ${SOURCES})
target_include_directories(blackjack_core PUBLIC include)

# Create main executable
add_executable(blackjack_trainer src/main.cpp)
target_link_libraries(blackjack_trainer blackjack_core CLI11::CLI11)

# Enable testing
enable_testing()

# Find or download doctest
find_package(doctest QUIET)
if(NOT doctest_FOUND)
    # Download and configure doctest
    include(FetchContent)
    FetchContent_Declare(
        doctest
        GIT_REPOSITORY https://github.com/doctest/doctest.git
        GIT_TAG v2.4.12
        GIT_SHALLOW TRUE
    )
    FetchContent_MakeAvailable(doctest)
endif()

# Find or download CLI11
find_package(CLI11 QUIET)
if(NOT CLI11_FOUND)
    # Download and configure CLI11
    include(FetchContent)
    FetchContent_Declare(
        CLI11
        GIT_REPOSITORY https://github.com/CLIUtils/CLI11.git
        GIT_TAG v2.4.2
        GIT_SHALLOW TRUE
    )
    FetchContent_MakeAvailable(CLI11)
endif()

# Collect test source files
file(GLOB_RECURSE TEST_SOURCES "tests/*.cpp")

# Create test executable
add_executable(test_blackjack ${TEST_SOURCES})
target_link_libraries(test_blackjack 
    blackjack_core
    doctest::doctest
)
target_include_directories(test_blackjack PRIVATE include tests)

# Add test to CTest
add_test(NAME BlackjackTests COMMAND test_blackjack)

# Custom target to run tests
add_custom_target(check
    COMMAND ${CMAKE_CTEST_COMMAND} --verbose
    DEPENDS test_blackjack
    COMMENT "Running tests"
)

# Installation
install(TARGETS blackjack_trainer
    RUNTIME DESTINATION bin
)

# Print configuration summary
message(STATUS "")
message(STATUS "BlackjackTrainer Configuration Summary:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  C++ standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  Install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "")