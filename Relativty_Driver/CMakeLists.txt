cmake_minimum_required(VERSION 3.11)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

project(driver_Relativty)

option(USE_CLANG_TIDY "Checks the code with clang-tidy" OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(HIDAPI REQUIRED CONFIG)
find_package(OpenVR REQUIRED)
find_package(Python3 COMPONENTS Development REQUIRED)

set(HEADERS "include/Relativty_base_device.h" "include/Relativty_components.h" "include/Relativty_EmbeddedPython.h" "include/Relativty_HMDDriver.hpp" "include/Relativty_ServerDriver.hpp")
set(SOURCES "source/DriverFactory.cpp" "source/driverlog.cpp" "source/Relativty_EmbeddedPython.cpp" "source/Relativty_HMDDriver.cpp" "source/Relativty_ServerDriver.cpp")

source_group(headers FILES ${HEADERS})
source_group(sources FILES ${SOURCES})

if(${WIN32})
  add_definitions("-DRELATIVTY_EXPORT=__declspec(dllexport)")
  set(PLATFORM_LIBS Ws2_32 Setupapi User32)
else()
  add_definitions("-DRELATIVTY_EXPORT=")
endif()

add_library(${PROJECT_NAME} SHARED ${HEADERS} ${SOURCES})
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD_REQUIRED ON)
target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include" "${HIDAPI_INCLUDE_DIR}" "${OPENVR_INCLUDE_DIR}")

if(${USE_CLANG_TIDY})
  find_program(CLANG_TIDY_EXE NAMES "clang-tidy" DOC "Path to clang-tidy executable")
  if(NOT CLANG_TIDY_EXE)
    message(STATUS "clang-tidy not found.")
  else()
    message(STATUS "clang-tidy found: ${CLANG_TIDY_EXE}")
    set(DO_CLANG_TIDY "${CLANG_TIDY_EXE}" "-checks=bugprone-*,clang-analyzer-*,cppcoreguidelines-*,hicpp-*,modernize-*,performance-*,portability-*,readability-*,-hicpp-use-auto,-modernize-use-auto,-modernize-use-trailing-return-type,-hicpp-vararg,-cppcoreguidelines-pro-type-vararg,-readability-implicit-bool-conversion,-cppcoreguidelines-pro-bounds-array-to-pointer-decay,-hicpp-no-array-decay,-hicpp-use-nullptr,-cppcoreguidelines-pro-bounds-pointer-arithmetic,-readability-magic-numbers,-hicpp-deprecated-headers,-cppcoreguidelines-pro-type-union-access")
    set_target_properties(${PROJECT_NAME} PROPERTIES CXX_CLANG_TIDY "${DO_CLANG_TIDY}")
  endif()
endif()

target_link_libraries(${PROJECT_NAME} PUBLIC ${HIDAPI_LIBRARY} ${OPENVR_LIBRARY} Python3::Python ${PLATFORM_LIBS})
