cmake_minimum_required(VERSION 3.16)

project(csad2526ki405denysiakmykolaandriyovich10
    VERSION 0.1.0
    DESCRIPTION "Project for Denysiak Mykola Andriyovych"
    LANGUAGES CXX)

# === Compiler and global settings ===
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(MSVC)
    add_compile_options(/W4 /permissive-)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# === Collect source files (exclude build/, tests/, CMakeFiles/) ===
file(GLOB_RECURSE ALL_SOURCES CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/*.cpp"
    "${CMAKE_SOURCE_DIR}/*.c"
)

set(PROJECT_SOURCES "")
foreach(src IN LISTS ALL_SOURCES)
    if(NOT src MATCHES "/(build|CMakeFiles|tests)/")
        list(APPEND PROJECT_SOURCES "${src}")
    endif()
endforeach()

if(NOT PROJECT_SOURCES)
    message(FATAL_ERROR "No valid source files found outside tests/.")
endif()

# === Separate main.cpp from other sources ===
set(MAIN_SOURCE "")
foreach(src IN LISTS PROJECT_SOURCES)
    if(src MATCHES ".*/main\\.cpp$")
        set(MAIN_SOURCE "${src}")
        list(REMOVE_ITEM PROJECT_SOURCES "${src}")
    endif()
endforeach()

# === Library target ===
add_library(${PROJECT_NAME}_lib STATIC ${PROJECT_SOURCES})
target_include_directories(${PROJECT_NAME}_lib PUBLIC
    "${CMAKE_SOURCE_DIR}"
    "${CMAKE_SOURCE_DIR}/include"
)

# === Executable (only if main.cpp exists) ===
if(MAIN_SOURCE)
    add_executable(${PROJECT_NAME} ${MAIN_SOURCE})
    target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_lib)
    target_include_directories(${PROJECT_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/include")
endif()

# === GoogleTest integration ===
option(BUILD_TESTS "Build and run unit tests" ON)
if(BUILD_TESTS)
    enable_testing()

    find_package(GTest CONFIG QUIET)
    if(NOT GTest_FOUND)
        include(FetchContent)
        FetchContent_Declare(
            googletest
            GIT_REPOSITORY https://github.com/google/googletest.git
            GIT_TAG release-1.12.1
        )
        set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
        FetchContent_MakeAvailable(googletest)
    endif()

    if(TARGET GTest::gtest_main)
        set(GTEST_MAIN_TARGET GTest::gtest_main)
    elseif(TARGET gtest_main)
        set(GTEST_MAIN_TARGET gtest_main)
    else()
        message(FATAL_ERROR "GoogleTest main target not found!")
    endif()

    if(EXISTS "${CMAKE_SOURCE_DIR}/tests/unit_tests.cpp")
        add_executable(unit_tests "${CMAKE_SOURCE_DIR}/tests/unit_tests.cpp")
        target_link_libraries(unit_tests PRIVATE ${PROJECT_NAME}_lib ${GTEST_MAIN_TARGET})
        target_include_directories(unit_tests PRIVATE "${CMAKE_SOURCE_DIR}/include")
        include(GoogleTest)
        gtest_discover_tests(unit_tests)
        message(STATUS "✓ Added unit_tests target (tests/unit_tests.cpp)")
    else()
        message(STATUS "No tests found — skipping.")
    endif()
endif()

# === Install ===
install(TARGETS ${PROJECT_NAME} ${PROJECT_NAME}_lib
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# === Summary ===
message(STATUS "=== Project summary ===")
message(STATUS "Project: ${PROJECT_NAME} ${PROJECT_VERSION}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Sources: ${PROJECT_SOURCES}")
if(MAIN_SOURCE)
    message(STATUS "Main: ${MAIN_SOURCE}")
endif()
