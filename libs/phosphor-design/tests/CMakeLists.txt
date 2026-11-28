# SPDX-FileCopyrightText: 2026 Phosphor Works Team
# SPDX-License-Identifier: LGPL-2.1-or-later

# phosphorcomponents_add_test and the test isolation.
include(${CMAKE_CURRENT_LIST_DIR}/../../../cmake/PhosphorComponentsTesting.cmake)

# Every type of Phosphor.Design loads and instantiates in a plain engine with
# the static module linked in, and gives no QML warning.
phosphorcomponents_add_test(test_design_load PhosphorDesignQml PhosphorDesignQmlplugin)
string(JOIN "|" _phosphor_design_qml_joined ${_phosphor_design_qml})
target_compile_definitions(test_design_load PRIVATE
    PHOSPHOR_DESIGN_QML_FILES="${_phosphor_design_qml_joined}")
