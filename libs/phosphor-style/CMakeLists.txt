# SPDX-FileCopyrightText: 2026 Phosphor Works Team
# SPDX-License-Identifier: LGPL-2.1-or-later

cmake_minimum_required(VERSION 3.16)

# Library version. Bumped on each release.
set(PHOSPHORSTYLE_VERSION "0.1.0")

# Qt minimum, taken from the top-level project when there is one.
if(DEFINED QT_MIN_VERSION)
    set(PHOSPHORSTYLE_QT_MIN ${QT_MIN_VERSION})
else()
    set(PHOSPHORSTYLE_QT_MIN "6.10.0")
endif()

# Configured on its own (no project() yet): become a project. In the
# phosphor-components tree, or in an app's tree, the top-level project is kept.
if(NOT PROJECT_VERSION)
    project(PhosphorStyle VERSION ${PHOSPHORSTYLE_VERSION} LANGUAGES CXX)
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_AUTOMOC ON)
endif()

find_package(Qt6 ${PHOSPHORSTYLE_QT_MIN} REQUIRED COMPONENTS Core Qml Quick)
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
# Phosphor.Style: the Qt Quick Controls style
# ═══════════════════════════════════════════════════════════════════════════════
#
# Every file of the module, sorted. The static module, the installed plugin, the
# install rule and the load test all read this one list. A new file also goes
# into qml/Phosphor/Style/qmldir, which the storybook reads.

set(_phosphor_style_qml
    qml/Phosphor/Style/ApplicationWindow.qml
    qml/Phosphor/Style/BusyIndicator.qml
    qml/Phosphor/Style/Button.qml
    qml/Phosphor/Style/CheckBox.qml
    qml/Phosphor/Style/ComboBox.qml
    qml/Phosphor/Style/Frame.qml
    qml/Phosphor/Style/ItemDelegate.qml
    qml/Phosphor/Style/Label.qml
    qml/Phosphor/Style/Menu.qml
    qml/Phosphor/Style/MenuItem.qml
    qml/Phosphor/Style/MenuSeparator.qml
    qml/Phosphor/Style/Pane.qml
    qml/Phosphor/Style/Popup.qml
    qml/Phosphor/Style/ProgressBar.qml
    qml/Phosphor/Style/RadioButton.qml
    qml/Phosphor/Style/ScrollBar.qml
    qml/Phosphor/Style/ScrollIndicator.qml
    qml/Phosphor/Style/ScrollView.qml
    qml/Phosphor/Style/Slider.qml
    qml/Phosphor/Style/Switch.qml
    qml/Phosphor/Style/TabBar.qml
    qml/Phosphor/Style/TabButton.qml
    qml/Phosphor/Style/TextField.qml
    qml/Phosphor/Style/ToolButton.qml
    qml/Phosphor/Style/ToolTip.qml
)

phosphor_components_add_qml_module(Style
    URI Phosphor.Style
    LIBRARY_VERSION ${PHOSPHORSTYLE_VERSION}
    QML_FILES ${_phosphor_style_qml}
    USES Design
)

# ═══════════════════════════════════════════════════════════════════════════════
# Tests
# ═══════════════════════════════════════════════════════════════════════════════

if(CMAKE_PROJECT_NAME STREQUAL "PhosphorStyle" OR PHOSPHOR_COMPONENTS_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
