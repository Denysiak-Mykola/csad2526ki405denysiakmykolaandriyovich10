cmake_minimum_required(VERSION 3.16)

project(csad2526ki405denysiakmykolaandriyovich10
    VERSION 0.1.0
    DESCRIPTION "Project generated CMake configuration"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(MSVC)
    add_compile_options(/W4 /permissive-)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Collect all .cpp/.c sources but exclude tests directory
file(GLOB_RECURSE ALL_SOURCES CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/*.cpp"
    "${CMAKE_SOURCE_DIR}/*.c"
)

set(PROJECT_SOURCES "")
foreach(f IN LISTS ALL_SOURCES)
    if(NOT f MATCHES "/tests/")
        list(APPEND PROJECT_SOURCES "${f}")
    endif()
endforeach()

if(NOT PROJECT_SOURCES)
    message(WARNING "No non-test source files found. Add sources to src/ or repo root.")
else()
    # Build a library from project sources so tests can link against it
    add_library(${PROJECT_NAME}_lib STATIC ${PROJECT_SOURCES})
    target_include_directories(${PROJECT_NAME}_lib PUBLIC
        "${CMAKE_SOURCE_DIR}"
        "${CMAKE_SOURCE_DIR}/include"
    )
endif()

# Optionally create a runnable executable if a main exists at conventional locations
file(GLOB MAIN_FILES CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/src/main.cpp"
    "${CMAKE_SOURCE_DIR}/main.cpp"
)
if(MAIN_FILES AND TARGET ${PROJECT_NAME}_lib)
    add_executable(${PROJECT_NAME} ${MAIN_FILES})
    target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_lib)
    target_include_directories(${PROJECT_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/include")
endif()

# ----- testing support (GoogleTest) -----
option(BUILD_TESTS "Build tests" ON)
if(BUILD_TESTS)
    enable_testing()
    include(FetchContent)
    FetchContent_Declare(
        googletest
        URL https://github.com/google/googletest/archive/refs/tags/release-1.14.0.zip
    )
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    if(EXISTS "${CMAKE_SOURCE_DIR}/tests/CMakeLists.txt")
        add_subdirectory(tests)
    else()
        if(EXISTS "${CMAKE_SOURCE_DIR}/tests/unit_tests.cpp")
            add_executable(unit_tests
                "${CMAKE_SOURCE_DIR}/tests/unit_tests.cpp"
            )
            target_include_directories(unit_tests PRIVATE
                "${CMAKE_SOURCE_DIR}"
                "${CMAKE_SOURCE_DIR}/include"
            )
            target_link_libraries(unit_tests PRIVATE gtest_main)
            # If project library exists, link it so tests use same implementation
            if(TARGET ${PROJECT_NAME}_lib)
                target_link_libraries(unit_tests PRIVATE ${PROJECT_NAME}_lib)
            endif()
            include(GoogleTest)
            gtest_discover_tests(unit_tests)
            message(STATUS "Added unit_tests target (tests/unit_tests.cpp) and linked GoogleTest")
        else()
            message(STATUS "No tests/CMakeLists.txt and no tests/unit_tests.cpp found; skipping tests.")
        endif()
    endif()
endif()

install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

message(STATUS "Project: ${PROJECT_NAME} ${PROJECT_VERSION}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Sources found: ${PROJECT_SOURCES}")