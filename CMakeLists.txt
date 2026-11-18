# SPDX-FileCopyrightText: 2026 fuddlesworth
# SPDX-License-Identifier: LGPL-2.1-or-later
#
# phosphor-components: the QML components the Phosphor apps share, as the
# Phosphor.Components module (libs/phosphor-components). They build on
# phosphor-libs, the commit cmake/PhosphorComponentsDependencies.cmake pins.
#
# Standalone (`cmake --workflow --preset dev`) this tree adds phosphor-libs and
# then the library. An app that adds it as a subproject (PlasmaZones) has added
# phosphor-libs already, and its pin is the one in use.

cmake_minimum_required(VERSION 3.16)

project(PhosphorComponents VERSION 0.1.0 LANGUAGES C CXX)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(PHOSPHOR_COMPONENTS_TOP_LEVEL ON)
else()
    set(PHOSPHOR_COMPONENTS_TOP_LEVEL OFF)
endif()

if(PHOSPHOR_COMPONENTS_TOP_LEVEL)
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTORCC ON)
    set(CMAKE_AUTOMOC_PARALLEL_ENABLED ON)

    find_program(CCACHE_PROGRAM ccache)
    if(CCACHE_PROGRAM)
        set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
        set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    endif()

    set(QT_MIN_VERSION "6.10.0")
    set(KF_MIN_VERSION "6.26.0")
    find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)
    set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

    option(BUILD_TESTING "Build the test suite" OFF)

    include(KDEInstallDirs)
    include(KDECMakeSettings)
    include(KDECompilerSettings NO_POLICY_SCOPE)
    include(FeatureSummary)

    add_compile_definitions(QT_NO_CAST_FROM_ASCII)

    include(KDEClangFormat)
    file(GLOB_RECURSE PHOSPHOR_COMPONENTS_CLANG_FORMAT_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/libs/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/libs/*.h
    )
    kde_clang_format(${PHOSPHOR_COMPONENTS_CLANG_FORMAT_FILES})

    # The components draw through Kirigami's theme and controls.
    find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS Kirigami)
endif()

if(NOT DEFINED QT_MIN_VERSION)
    set(QT_MIN_VERSION "6.10.0")
endif()

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
find_package(Qt6 ${QT_MIN_VERSION} QUIET COMPONENTS LinguistTools)

if(QT_KNOWN_POLICY_QTP0001)
    qt_policy(SET QTP0001 NEW)
endif()
if(QT_KNOWN_POLICY_QTP0004)
    qt_policy(SET QTP0004 NEW)
endif()

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/PhosphorComponentsDependencies.cmake")
phosphor_components_add_phosphor_libs()
list(APPEND CMAKE_MODULE_PATH "${PHOSPHOR_LIBS_CMAKE_DIR}")

add_subdirectory(libs/phosphor-components) # Phosphor.Components QML module and its catalog

if(PHOSPHOR_COMPONENTS_TOP_LEVEL)
    feature_summary(WHAT REQUIRED_PACKAGES_FOUND REQUIRED_PACKAGES_NOT_FOUND
                         OPTIONAL_PACKAGES_FOUND OPTIONAL_PACKAGES_NOT_FOUND
                    FATAL_ON_MISSING_REQUIRED_PACKAGES)
endif()
