# SPDX-FileCopyrightText: 2026 Phosphor Works Team
# SPDX-License-Identifier: LGPL-2.1-or-later

# phosphorcomponents_add_test and the test isolation.
include(${CMAKE_CURRENT_LIST_DIR}/../../../cmake/PhosphorComponentsTesting.cmake)

# Every component loads in a plain engine with the static module linked in, and
# org.phosphor.animation beside it where phosphor-libs is in the tree (always,
# except for a configure of this library on its own).
phosphorcomponents_add_test(test_components_load PhosphorComponentsQmlplugin)
string(JOIN "|" _phosphor_components_qml_joined ${_phosphor_components_qml})
target_compile_definitions(test_components_load PRIVATE
    PHOSPHOR_COMPONENTS_QML_FILES="${_phosphor_components_qml_joined}")
if(TARGET PhosphorAnimationQmlplugin)
    target_link_libraries(test_components_load PRIVATE PhosphorAnimationQmlplugin)
    target_compile_definitions(test_components_load PRIVATE PHOSPHOR_COMPONENTS_WITH_ANIMATION)
endif()

# The catalogs resolve, the English plural forms included.
if(TARGET phosphor_components_translations)
    phosphorcomponents_add_test(test_components_translations)
    target_compile_definitions(test_components_translations PRIVATE
        PHOSPHOR_COMPONENTS_QM_DIR="${CMAKE_CURRENT_BINARY_DIR}/..")
    add_dependencies(test_components_translations phosphor_components_translations)
endif()
