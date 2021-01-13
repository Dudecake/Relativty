# Taken from: https://github.com/henriheimann/rollivr/blob/master/software/cmake/FindOpenVR.cmake
# Originaly taken from: https://github.com/ospray/module_openvr/blob/master/cmake/FindOpenVR.cmake

# Find the OpenVR SDK
# NOTE: there is no default installation path as the code needs to be build
# This module defines:
# OPENVR_FOUND, if false do not try to link against the Open VR SDK
# OPENVR_LIBRARY, the name of the Open VR SDK library to link against
# OPENVR_INCLUDE_DIR, the Open VR SDK include directory
#
# You can also specify the environment variable OPENVR_DIR or define it with
# -DOPENVR_DIR=... to hint at the module where to search for the Open VR SDK if it's
# installed in a non-standard location.

find_path(OPENVR_INCLUDE_DIR openvr.h
        HINTS
        ${OPENVR_DIR}
        $ENV{OPENVR_DIR}
        PATH_SUFFIXES headers/
        # TODO: Unsure on handling of the possible default install locations
        PATHS
        ~/Library/Frameworks
        /Library/Frameworks
        /usr/local/include/
        /usr/include/
        /sw # Fink
        /opt/local # DarwinPorts
        /opt/csw # Blastwave
        /opt
        )

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    if (UNIX OR MINGW)
        set(LIB_PATH_SUFFIX "lib/linux64/")
    elseif (MSVC)
        set(LIB_PATH_SUFFIX "lib/win64/")
    else()
        message(ERROR "Error: Unsupported 64 bit configuration")
    endif()
else()
    if (UNIX OR MINGW)
        set(LIB_PATH_SUFFIX "lib/linux32/")
    elseif (MSVC)
        set(LIB_PATH_SUFFIX "lib/win32/")
    elseif(APPLE)
        set(LIB_PATH_SUFFIX "lib/osx32/")
    else()
        message(ERROR "Error: Unsupported 32 bit configuration")
    endif()
endif()

find_library(OPENVR_LIBRARY_TMP NAMES openvr_api openr_api.lib
        HINTS
        ${OPENVR_DIR}
        $ENV{OPENVR_DIR}
        PATH_SUFFIXES ${LIB_PATH_SUFFIX}
        # TODO: I don't know if these will be correct if people have installed
        # the library on to their system instead of just using the git repo or w/e
        PATHS
        /sw
        /opt/local
        /opt/csw
        /opt
        )

set(OPENVR_FOUND FALSE)
if (OPENVR_LIBRARY_TMP AND OPENVR_INCLUDE_DIR)
    set(OPENVR_LIBRARY ${OPENVR_LIBRARY_TMP} CACHE STRING "Which OpenVR library to link against")
    set(OPENVR_LIBRARY_TMP ${OPENVR_LIBRARY_TMP} CACHE INTERNAL "")
    set(OPENVR_FOUND TRUE)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OpenVR REQUIRED_VARS OPENVR_LIBRARY OPENVR_INCLUDE_DIR)
