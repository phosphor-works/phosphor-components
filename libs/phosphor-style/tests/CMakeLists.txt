# SPDX-FileCopyrightText: 2026 Phosphor Works Team
# SPDX-License-Identifier: LGPL-2.1-or-later

# phosphorcomponents_add_test and the test isolation.
include(${CMAKE_CURRENT_LIST_DIR}/../../../cmake/PhosphorComponentsTesting.cmake)

# Every control of Phosphor.Style loads and instantiates in a plain engine with
# the static modules linked in, and gives no QML warning.
phosphorcomponents_add_test(test_style_load
    PhosphorStyleQml PhosphorStyleQmlplugin PhosphorDesignQmlplugin)
string(JOIN "|" _phosphor_style_qml_joined ${_phosphor_style_qml})
target_compile_definitions(test_style_load PRIVATE
    PHOSPHOR_STYLE_QML_FILES="${_phosphor_style_qml_joined}")
