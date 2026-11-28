# SPDX-FileCopyrightText: 2026 Phosphor Works Team
# SPDX-License-Identifier: LGPL-2.1-or-later

cmake_minimum_required(VERSION 3.16)

# Library version. Bumped on each release.
set(PHOSPHORDESIGN_VERSION "0.1.0")

# Qt minimum, taken from the top-level project when there is one.
if(DEFINED QT_MIN_VERSION)
    set(PHOSPHORDESIGN_QT_MIN ${QT_MIN_VERSION})
else()
    set(PHOSPHORDESIGN_QT_MIN "6.10.0")
endif()

# Configured on its own (no project() yet): become a project. In the
# phosphor-components tree, or in an app's tree, the top-level project is kept.
if(NOT PROJECT_VERSION)
    project(PhosphorDesign VERSION ${PHOSPHORDESIGN_VERSION} LANGUAGES CXX)
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_AUTOMOC ON)
endif()

find_package(Qt6 ${PHOSPHORDESIGN_QT_MIN} REQUIRED COMPONENTS Core Qml Quick)
if(COMMAND qt_policy)
    qt_policy(SET QTP0001 NEW)
    qt_policy(SET QTP0004 NEW)
endif()

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(NOT DEFINED KDE_INSTALL_QMLDIR)
    include(GNUInstallDirs)
    set(KDE_INSTALL_QMLDIR ${CMAKE_INSTALL_LIBDIR}/qt6/qml)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/PhosphorComponentsQmlModule.cmake)

# ═══════════════════════════════════════════════════════════════════════════════
# Phosphor.Design: the tokens, the motion types and the components
# ═══════════════════════════════════════════════════════════════════════════════
#
# Every file of the module, sorted. The static module, the installed plugin, the
# install rule and the load test all read this one list. A new file also goes
# into qml/Phosphor/Design/qmldir, which the storybook reads.

set(_phosphor_design_qml
    qml/Phosphor/Design/Artwork.qml
    qml/Phosphor/Design/Avatar.qml
    qml/Phosphor/Design/Badge.qml
    qml/Phosphor/Design/BarChip.qml
    qml/Phosphor/Design/Bars.qml
    qml/Phosphor/Design/BigSlider.qml
    qml/Phosphor/Design/Fade.qml
    qml/Phosphor/Design/FlowSpring.qml
    qml/Phosphor/Design/FocusRing.qml
    qml/Phosphor/Design/Icon.qml
    qml/Phosphor/Design/IconButton.qml
    qml/Phosphor/Design/Icons.qml
    qml/Phosphor/Design/Keycap.qml
    qml/Phosphor/Design/LayoutPreview.qml
    qml/Phosphor/Design/ListRow.qml
    qml/Phosphor/Design/Meter.qml
    qml/Phosphor/Design/Metrics.qml
    qml/Phosphor/Design/MonthGrid.qml
    qml/Phosphor/Design/Motion.qml
    qml/Phosphor/Design/NavList.qml
    qml/Phosphor/Design/NotificationCard.qml
    qml/Phosphor/Design/PanelHeader.qml
    qml/Phosphor/Design/PanelPage.qml
    qml/Phosphor/Design/Segmented.qml
    qml/Phosphor/Design/SettingGroup.qml
    qml/Phosphor/Design/SettingRow.qml
    qml/Phosphor/Design/ShellBody.qml
    qml/Phosphor/Design/SnapSpring.qml
    qml/Phosphor/Design/Sparkline.qml
    qml/Phosphor/Design/Spinner.qml
    qml/Phosphor/Design/StretchIndicator.qml
    qml/Phosphor/Design/Surface.qml
    qml/Phosphor/Design/SwatchPicker.qml
    qml/Phosphor/Design/Theme.qml
    qml/Phosphor/Design/Tile.qml
    qml/Phosphor/Design/Tint.qml
    qml/Phosphor/Design/TrailSpring.qml
    qml/Phosphor/Design/Visualizer.qml
    qml/Phosphor/Design/WindowFrame.qml
    qml/Phosphor/Design/WorkspaceStrip.qml
)

phosphor_components_add_qml_module(Design
    URI Phosphor.Design
    LIBRARY_VERSION ${PHOSPHORDESIGN_VERSION}
    QML_FILES ${_phosphor_design_qml}
    SINGLETONS
        qml/Phosphor/Design/Icons.qml
        qml/Phosphor/Design/Metrics.qml
        qml/Phosphor/Design/Motion.qml
        qml/Phosphor/Design/Theme.qml
)

# ═══════════════════════════════════════════════════════════════════════════════
# Tests
# ═══════════════════════════════════════════════════════════════════════════════

if(CMAKE_PROJECT_NAME STREQUAL "PhosphorDesign" OR PHOSPHOR_COMPONENTS_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
