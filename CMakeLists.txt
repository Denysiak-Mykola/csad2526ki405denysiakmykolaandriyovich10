cmake_minimum_required(VERSION 3.16)

project(csad2526ki405denysiakmykolaandriyovich10
    VERSION 0.1.0
    DESCRIPTION "Project generated CMake configuration"
    LANGUAGES CXX)

# ----- basic settings -----
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Enable useful defaults for multi-config generators (Visual Studio / MSVC)
if(MSVC)
    add_compile_options(/W4 /permissive-)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# ----- source discovery -----
# Prefer src/ and include/ structure; fallback to all .cpp files if src missing
if(EXISTS "${CMAKE_SOURCE_DIR}/src")
    file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS
        "${CMAKE_SOURCE_DIR}/src/*.cpp"
        "${CMAKE_SOURCE_DIR}/src/*.c")
else()
    file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS
        "${CMAKE_SOURCE_DIR}/*.cpp"
        "${CMAKE_SOURCE_DIR}/*.c")
endif()

# Fallback when no sources found
if(NOT PROJECT_SOURCES)
    message(WARNING "No source files found. Add sources to src/ or repo root.")
endif()

# ----- target -----
add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})
target_include_directories(${PROJECT_NAME} PRIVATE
    "${CMAKE_SOURCE_DIR}/include"
)

# Link libraries here if needed:
# target_link_libraries(${PROJECT_NAME} PRIVATE your_lib)

# ----- testing support -----
option(BUILD_TESTS "Build tests" ON)
if(BUILD_TESTS)
    enable_testing()
    if(EXISTS "${CMAKE_SOURCE_DIR}/tests/CMakeLists.txt")
        add_subdirectory(tests)
    else()
        message(STATUS "No tests/CMakeLists.txt found; skip adding tests subdirectory.")
    endif()
endif()

# ----- install (optional) -----
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

# ----- helpful variables -----
message(STATUS "Project: ${PROJECT_NAME} ${PROJECT_VERSION}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Sources found: ${PROJECT_SOURCES}")