# SPDX-FileCopyrightText: 2026 Phosphor Works Team
# SPDX-License-Identifier: LGPL-2.1-or-later

find_package(Qt6 REQUIRED COMPONENTS Test Quick)

# Shared test isolation: a private D-Bus session and a per-target XDG sandbox.
# The module lives in phosphor-libs, whose top-level CMakeLists names its cmake/
# directory PHOSPHOR_LIBS_CMAKE_DIR. The guard covers a configure of this
# library on its own, where nothing has set it.
if(PHOSPHOR_LIBS_CMAKE_DIR AND EXISTS "${PHOSPHOR_LIBS_CMAKE_DIR}/PhosphorTestIsolation.cmake")
    include(${PHOSPHOR_LIBS_CMAKE_DIR}/PhosphorTestIsolation.cmake)
else()
    # Stand-ins so the call sites below need no guard of their own.
    # phosphor_append_test_environment is reproduced EXACTLY, because callers
    # use it for QT_QPA_PLATFORM=offscreen, which the tests need to pass at all.
    function(phosphor_apply_test_isolation _target)
    endfunction()
    function(phosphor_append_test_environment _test_name)
        set_property(TEST ${_test_name} APPEND PROPERTY ENVIRONMENT ${ARGN})
    endfunction()
endif()

function(phosphorcomponents_add_test name)
    add_executable(${name} ${name}.cpp)
    target_link_libraries(${name}
        PRIVATE
            Qt6::Core
            Qt6::Quick
            Qt6::Test
            ${ARGN}
    )
    add_test(NAME ${name} COMMAND ${name})
    phosphor_apply_test_isolation(${name})
    set_property(TEST ${name} APPEND PROPERTY LABELS "phosphorcomponents")
    phosphor_append_test_environment(${name} "QT_QPA_PLATFORM=offscreen")
endfunction()

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
