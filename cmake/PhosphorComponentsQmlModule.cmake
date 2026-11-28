# SPDX-FileCopyrightText: 2026 Phosphor Works Team
# SPDX-License-Identifier: LGPL-2.1-or-later
#
# phosphor_components_add_qml_module(<Name>
#     URI <uri>
#     LIBRARY_VERSION <version>
#     QML_FILES <file>...
#     [SINGLETONS <file>...]
#     [USES <Name>...])
#
# Makes a module of this repository that has only QML files, in the two forms
# that an app uses:
#
#   Phosphor<Name>Qml (alias Phosphor<Name>::Phosphor<Name>Qml) and
#   Phosphor<Name>Qmlplugin
#       The STATIC module and its plugin. An app links the two.
#   Phosphor<Name>QmlShared and Phosphor<Name>QmlSharedplugin
#       The same module as a plugin in the QML directory of Qt, built when
#       PHOSPHOR_COMPONENTS_QML_INSTALL is ON.
#
# USES names the modules of this function that the QML files import. The static
# module links them, and the compiler of the QML files finds their types.
#
# The directory of the QML files also holds a qmldir that a person writes. A
# tool that loads the files from the source tree reads it. The storybook of the
# design-language repository does so, and a saved file then shows without a
# build. The configure fails when that qmldir and QML_FILES name different
# types.

include_guard(GLOBAL)

option(PHOSPHOR_COMPONENTS_QML_INSTALL "Also build each QML module as an installed plugin" ON)

# Fails the configure when the qmldir in <directory> names other files, or other
# singletons, than the two lists.
function(_phosphor_components_check_qmldir directory files singletons)
    set(_qmldir "${directory}/qmldir")
    if(NOT EXISTS "${_qmldir}")
        message(FATAL_ERROR "${directory} has no qmldir. The storybook loads the module from this directory.")
    endif()
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${_qmldir}")

    set(_listed)
    set(_listed_singletons)
    file(STRINGS "${_qmldir}" _lines)
    foreach(_line IN LISTS _lines)
        if(_line MATCHES "^(singleton )?[A-Za-z0-9_]+ [0-9.]+ ([A-Za-z0-9_]+\\.qml)$")
            list(APPEND _listed "${CMAKE_MATCH_2}")
            if(CMAKE_MATCH_1)
                list(APPEND _listed_singletons "${CMAKE_MATCH_2}")
            endif()
        endif()
    endforeach()

    set(_named)
    foreach(_file IN LISTS files)
        get_filename_component(_basename "${_file}" NAME)
        list(APPEND _named "${_basename}")
    endforeach()
    set(_named_singletons)
    foreach(_file IN LISTS singletons)
        get_filename_component(_basename "${_file}" NAME)
        list(APPEND _named_singletons "${_basename}")
    endforeach()

    foreach(_list _listed _listed_singletons _named _named_singletons)
        list(SORT ${_list})
    endforeach()
    if(NOT "${_listed}" STREQUAL "${_named}")
        message(FATAL_ERROR "${_qmldir} and QML_FILES name different files.\n"
                            "  qmldir:    ${_listed}\n  QML_FILES: ${_named}")
    endif()
    if(NOT "${_listed_singletons}" STREQUAL "${_named_singletons}")
        message(FATAL_ERROR "${_qmldir} and SINGLETONS name different singletons.\n"
                            "  qmldir:     ${_listed_singletons}\n  SINGLETONS: ${_named_singletons}")
    endif()
endfunction()

function(phosphor_components_add_qml_module name)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "URI;LIBRARY_VERSION" "QML_FILES;SINGLETONS;USES")
    if(arg_UNPARSED_ARGUMENTS OR NOT arg_URI OR NOT arg_LIBRARY_VERSION OR NOT arg_QML_FILES)
        message(FATAL_ERROR "phosphor_components_add_qml_module(${name}): URI, LIBRARY_VERSION and QML_FILES "
                            "are necessary, got: ${ARGN}")
    endif()

    string(REPLACE "." "/" _path "${arg_URI}")
    set(_static Phosphor${name}Qml)
    set(_shared Phosphor${name}QmlShared)

    # The resource path of each file is its basename, so that it agrees with the URI.
    foreach(_qml IN LISTS arg_QML_FILES)
        get_filename_component(_basename "${_qml}" NAME)
        set_source_files_properties("${_qml}" PROPERTIES QT_RESOURCE_ALIAS "${_basename}")
    endforeach()
    if(arg_SINGLETONS)
        set_source_files_properties(${arg_SINGLETONS} PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
    endif()

    list(GET arg_QML_FILES 0 _first)
    get_filename_component(_directory "${_first}" DIRECTORY)
    get_filename_component(_directory "${_directory}" ABSOLUTE)
    _phosphor_components_check_qmldir("${_directory}" "${arg_QML_FILES}" "${arg_SINGLETONS}")

    qt_add_qml_module(${_static}
        URI ${arg_URI}
        VERSION 1.0
        STATIC
        QML_FILES ${arg_QML_FILES}
        IMPORT_PATH ${CMAKE_BINARY_DIR}/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/${_path}
    )
    add_library(Phosphor${name}::${_static} ALIAS ${_static})
    target_link_libraries(${_static} PUBLIC Qt6::Qml Qt6::Quick)
    foreach(_use IN LISTS arg_USES)
        target_link_libraries(${_static} PUBLIC Phosphor${_use}Qml)
    endforeach()

    if(NOT PHOSPHOR_COMPONENTS_QML_INSTALL)
        return()
    endif()
    if(NOT COMMAND phosphor_install_devel)
        # Configured on its own: the install functions come with phosphor-libs.
        find_package(PhosphorPaths REQUIRED)
    endif()

    qt_add_qml_module(${_shared}
        URI ${arg_URI}
        VERSION 1.0
        SHARED
        QML_FILES ${arg_QML_FILES}
        IMPORT_PATH ${CMAKE_BINARY_DIR}/qml_install
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml_install/${_path}
    )
    target_link_libraries(${_shared} PUBLIC Qt6::Qml Qt6::Quick)
    foreach(_use IN LISTS arg_USES)
        # The installed plugin finds the other module at run time. The compiler
        # of the QML files needs its type information first.
        add_dependencies(${_shared} Phosphor${_use}QmlShared)
    endforeach()
    set_target_properties(${_shared} PROPERTIES
        VERSION ${arg_LIBRARY_VERSION}
        SOVERSION 0
    )
    set_target_properties(${_shared}plugin PROPERTIES
        INSTALL_RPATH "$ORIGIN"
        PREFIX "lib"
    )
    set(_install_dir "${KDE_INSTALL_QMLDIR}/${_path}")
    phosphor_install_devel(TARGETS ${_shared} ${_shared}plugin
        RUNTIME DESTINATION ${_install_dir}
        LIBRARY DESTINATION ${_install_dir}
    )
    phosphor_install_devel(FILES
            ${CMAKE_BINARY_DIR}/qml_install/${_path}/qmldir
            ${CMAKE_BINARY_DIR}/qml_install/${_path}/${_shared}.qmltypes
            ${arg_QML_FILES}
        DESTINATION ${_install_dir}
    )
endfunction()
