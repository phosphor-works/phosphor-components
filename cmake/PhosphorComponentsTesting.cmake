# SPDX-FileCopyrightText: 2026 Phosphor Works Team
# SPDX-License-Identifier: LGPL-2.1-or-later
#
# phosphorcomponents_add_test(<name> [<library>...])
#
# Adds the test <name> from <name>.cpp in the current directory. It links Qt
# Core, Quick and Test and the libraries given, runs on the offscreen platform
# and has the label "phosphorcomponents".

# No include guard: the Qt targets that find_package makes belong to the
# directory that includes this file.
find_package(Qt6 REQUIRED COMPONENTS Test Quick)

# Shared test isolation: a private D-Bus session and a per-target XDG sandbox.
# The module lives in phosphor-libs, whose top-level CMakeLists names its cmake/
# directory PHOSPHOR_LIBS_CMAKE_DIR. The guard covers a configure of one
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
