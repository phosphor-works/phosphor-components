# SPDX-FileCopyrightText: 2026 Phosphor Works Team
# SPDX-License-Identifier: LGPL-2.1-or-later
#
# phosphor-components: the Phosphor.Components QML module.
#
#   * PhosphorComponentsQml (PhosphorComponents::PhosphorComponentsQml): the
#     module as a STATIC QML library, for an app that builds this tree with its
#     own and links it into its executables (Q_IMPORT_QML_PLUGIN with
#     Phosphor_ComponentsPlugin).
#   * PhosphorComponentsQmlShared: the same module as a plugin installed into
#     Qt's QML directory, for everything else (PHOSPHOR_COMPONENTS_QML_INSTALL).
#
# The strings go through qsTr(), each component's file name being its context,
# into this library's own catalog, translations/phosphor-components_<lang>.ts,
# installed to the suite's shared share/phosphor-works/translations.

cmake_minimum_required(VERSION 3.16)

set(PHOSPHORCOMPONENTS_VERSION "0.1.0")

# The Qt floor this library requires. Taken from the top-level QT_MIN_VERSION
# when built in-tree so the two cannot drift, with its own value for a
# standalone build, where that variable does not exist.
if(DEFINED QT_MIN_VERSION)
    set(PHOSPHORCOMPONENTS_QT_MIN ${QT_MIN_VERSION})
else()
    set(PHOSPHORCOMPONENTS_QT_MIN "6.10.0")
endif()

if(NOT PROJECT_VERSION)
    project(PhosphorComponents VERSION ${PHOSPHORCOMPONENTS_VERSION} LANGUAGES CXX)
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_AUTOMOC ON)
endif()

# Qml and Quick build the module. The components also import QtQuick.Controls,
# QtQuick.Layouts, QtQuick.Dialogs, org.kde.kirigami and org.phosphor.animation
# (phosphor-libs), which the engine that loads them resolves at run time.
find_package(Qt6 ${PHOSPHORCOMPONENTS_QT_MIN} REQUIRED COMPONENTS Core Qml Quick)
find_package(Qt6 ${PHOSPHORCOMPONENTS_QT_MIN} QUIET COMPONENTS LinguistTools)
if(COMMAND qt_policy)
    qt_policy(SET QTP0001 NEW)
    qt_policy(SET QTP0004 NEW)
endif()

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(NOT DEFINED KDE_INSTALL_QMLDIR)
    include(GNUInstallDirs)
    set(KDE_INSTALL_QMLDIR ${CMAKE_INSTALL_LIBDIR}/qt6/qml)
endif()
if(NOT DEFINED KDE_INSTALL_DATADIR)
    include(GNUInstallDirs)
    set(KDE_INSTALL_DATADIR ${CMAKE_INSTALL_DATADIR})
endif()

# ═══════════════════════════════════════════════════════════════════════════════
# The module
# ═══════════════════════════════════════════════════════════════════════════════

set(_phosphor_components_qml
    qml/Phosphor/Components/AspectRatioBadge.qml
    qml/Phosphor/Components/AxisChevron.qml
    qml/Phosphor/Components/CapabilityBadgeRow.qml
    qml/Phosphor/Components/CategoryBadge.qml
    qml/Phosphor/Components/CategoryMenuButton.qml
    qml/Phosphor/Components/DecorationPreviewCard.qml
    qml/Phosphor/Components/LayoutCard.qml
    qml/Phosphor/Components/ParameterEditor.qml
    qml/Phosphor/Components/ParameterRow.qml
    qml/Phosphor/Components/ParameterSection.qml
    qml/Phosphor/Components/PopupFrame.qml
    qml/Phosphor/Components/ShaderErrorBanner.qml
    qml/Phosphor/Components/ShaderParamsEditor.qml
    qml/Phosphor/Components/ShaderPreviewPlaceholder.qml
    qml/Phosphor/Components/StripEmptyState.qml
    qml/Phosphor/Components/ZoneColorDefaults.qml
    qml/Phosphor/Components/ZonePreview.qml
)
foreach(_qml IN LISTS _phosphor_components_qml)
    get_filename_component(_qml_basename ${_qml} NAME)
    set_source_files_properties(${_qml} PROPERTIES QT_RESOURCE_ALIAS ${_qml_basename})
endforeach()
set_source_files_properties(qml/Phosphor/Components/ZoneColorDefaults.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(PhosphorComponentsQml
    URI Phosphor.Components
    VERSION 1.0
    STATIC
    QML_FILES ${_phosphor_components_qml}
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/Phosphor/Components
)
if(NOT COMMAND phosphor_install_targets)
    # Configured on its own: the install functions come with phosphor-libs.
    find_package(PhosphorPaths REQUIRED)
endif()
add_library(PhosphorComponents::PhosphorComponentsQml ALIAS PhosphorComponentsQml)
target_link_libraries(PhosphorComponentsQml
    PUBLIC
        Qt6::Qml
        Qt6::Quick
)

option(PHOSPHOR_COMPONENTS_QML_INSTALL "Also build Phosphor.Components as an installed plugin" ON)
if(PHOSPHOR_COMPONENTS_QML_INSTALL)
    qt_add_qml_module(PhosphorComponentsQmlShared
        URI Phosphor.Components
        VERSION 1.0
        SHARED
        QML_FILES ${_phosphor_components_qml}
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml_install/Phosphor/Components
    )
    target_link_libraries(PhosphorComponentsQmlShared
        PUBLIC
            Qt6::Qml
            Qt6::Quick
    )
    set_target_properties(PhosphorComponentsQmlShared PROPERTIES
        VERSION ${PHOSPHORCOMPONENTS_VERSION}
        SOVERSION 0
    )
    set_target_properties(PhosphorComponentsQmlSharedplugin PROPERTIES
        INSTALL_RPATH "$ORIGIN"
        PREFIX "lib"
    )
    set(_phosphor_components_install_dir "${KDE_INSTALL_QMLDIR}/Phosphor/Components")
    phosphor_install_devel(TARGETS PhosphorComponentsQmlShared PhosphorComponentsQmlSharedplugin
        RUNTIME DESTINATION ${_phosphor_components_install_dir}
        LIBRARY DESTINATION ${_phosphor_components_install_dir}
    )
    phosphor_install_devel(FILES
            ${CMAKE_BINARY_DIR}/qml_install/Phosphor/Components/qmldir
            ${CMAKE_BINARY_DIR}/qml_install/Phosphor/Components/PhosphorComponentsQmlShared.qmltypes
            ${_phosphor_components_qml}
        DESTINATION ${_phosphor_components_install_dir}
    )
endif()

# ═══════════════════════════════════════════════════════════════════════════════
# Translations
# ═══════════════════════════════════════════════════════════════════════════════
#
# Unlike an application's catalog, the English one is compiled too: it holds
# the English plural forms of the qsTr() calls that pass a count, which the
# source text alone cannot give.

file(GLOB PHOSPHOR_COMPONENTS_TS_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/translations/phosphor-components_*.ts")

if(TARGET Qt6::lupdate)
    add_custom_target(phosphor-components-update-ts
        COMMENT "Updating the phosphor-components catalogs from the QML (lupdate)"
        COMMAND Qt6::lupdate -no-obsolete ${_phosphor_components_qml} -ts ${PHOSPHOR_COMPONENTS_TS_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()

if(TARGET Qt6::lrelease AND PHOSPHOR_COMPONENTS_TS_FILES)
    qt_add_lrelease(
        LRELEASE_TARGET phosphor_components_translations
        TS_FILES ${PHOSPHOR_COMPONENTS_TS_FILES}
        QM_FILES_OUTPUT_VARIABLE PHOSPHOR_COMPONENTS_QM_FILES
    )
    install(FILES ${PHOSPHOR_COMPONENTS_QM_FILES}
        DESTINATION ${KDE_INSTALL_DATADIR}/${PHOSPHOR_SUITE_DIRECTORY_NAME}/translations)
endif()

# ═══════════════════════════════════════════════════════════════════════════════
# Tests
# ═══════════════════════════════════════════════════════════════════════════════

if(CMAKE_PROJECT_NAME STREQUAL "PhosphorComponents" OR BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
