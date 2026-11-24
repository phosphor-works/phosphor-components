<!-- SPDX-FileCopyrightText: 2026 fuddlesworth -->
<!-- SPDX-License-Identifier: LGPL-2.1-or-later -->

# phosphor-components

`Phosphor.Components`, the QML components the Phosphor apps share: layout cards and zone previews, badges, popup
frames and the shader parameter editor. Qt 6 Quick and Kirigami, no C++ library of its own. PlasmaZones links it
as a static module. Other hosts can use the installed plugin. It builds on phosphor-libs.

The rules every phosphor-works repository follows come from the workspace repository, imported below. This file adds
phosphor-components' own. The shared Claude Code tooling (the command guard, `phosphor-works:build`,
`phosphor-works:debug`, `phosphor-works:code-audit`, the shared reviewers, the lesson index) comes from the
`phosphor-works` plugin, which `.claude/settings.json` enables and `workspace/tools/setup` installs.

@../workspace/claude/conventions.md

## Layout

- The one library is `libs/phosphor-components/`: QML in `qml/Phosphor/Components/`, catalogs in `translations/`,
  tests in `tests/`, its own `README.md` with the type table and host instructions.
- The root CMakeLists.txt adds phosphor-libs, includes phosphor-libs' `PhosphorSuite.cmake` (for
  `PHOSPHOR_SUITE_DIRECTORY_NAME`), then the library.
- `cmake/PhosphorComponentsDependencies.cmake` pins phosphor-libs. `nix/package.nix` repeats that pin.

## Targets and module

| Target | What it is |
| --- | --- |
| `PhosphorComponentsQml` (alias `PhosphorComponents::PhosphorComponentsQml`) | The STATIC module, URI `Phosphor.Components`, version 1.0 |
| `PhosphorComponentsQmlplugin` | Its generated static plugin. A host links it and calls `Q_IMPORT_QML_PLUGIN(Phosphor_ComponentsPlugin)` |
| `PhosphorComponentsQmlShared` and `PhosphorComponentsQmlSharedplugin` | The same module as a plugin installed to `${KDE_INSTALL_QMLDIR}/Phosphor/Components`, built when `PHOSPHOR_COMPONENTS_QML_INSTALL` is ON (the default) |
| `phosphor_components_translations` | The compiled catalogs, installed to `share/phosphor-works/translations` |
| `phosphor-components-update-ts` | Runs `lupdate -no-obsolete` over the module's QML into every `.ts` |

There is no C++ namespace, public header, include path or export macro. The module has QML files only.

## Layers

- phosphor-libs is the only suite dependency, and only at run time: the components import `org.phosphor.animation`.
  The module links Qt Qml and Quick only. The components also import QtQuick.Controls, QtQuick.Layouts,
  QtQuick.Dialogs and `org.kde.kirigami`, which the host engine resolves.
- Nothing here links or imports phosphor-shell-libs, phosphor-engine-libs or an app. A component takes plain values
  and reports user actions as signals. It reads no app state. A host injects settings, as `ZoneColorDefaults`
  takes a host object through `settingsSource`.

## License

Every file, tests included, is `LGPL-2.1-or-later`. The components came from PlasmaZones (GPL). Code that moves in
from an app is a relicense (see the conventions).

## How apps consume it

- PlasmaZones pins one commit in `cmake/PlasmaZonesDependencies.cmake` and repeats it in
  `packaging/nix/package.nix`. `plasmazones_add_phosphor_components()` adds this tree with CPM after phosphor-libs
  and forces `PHOSPHOR_COMPONENTS_QML_INSTALL` OFF, because the app links the static module.
- Build an app against a local checkout with `-DCPM_phosphor-components_SOURCE=<dir>`, or use the workspace
  superbuild (`cmake --workflow --preset plasmazones` in `../workspace`), which sets that for every library.
- After a change merges here, move the app's pin: VERSION, URL, FILE and SHA256 together, in both files.
- A host loads the `phosphor-components` catalog itself with a `QTranslator` (PlasmaZones does it in
  `translationloader.cpp`). The library's `README.md` has the snippet.

## As a subproject

- The root CMakeLists.txt sets `PHOSPHOR_COMPONENTS_TOP_LEVEL`. Only the top level sets the C++ standard, ccache,
  ECM and the KDE settings, `QT_NO_CAST_FROM_ASCII`, `BUILD_TESTING` and the feature summary. As a subproject the
  app's values are in force. `PHOSPHOR_COMPONENTS_QML_INSTALL` is a cache option in the app's tree too.
- `phosphor_components_add_phosphor_libs()` uses the app's phosphor-libs when `PhosphorIpc` already exists, and
  fetches nothing.
- The tests include `PhosphorTestIsolation.cmake` from `PHOSPHOR_LIBS_CMAKE_DIR` with an `EXISTS` guard, and apply
  it per target in `phosphorcomponents_add_test()`. Without phosphor-libs in the tree, a stand-in keeps the
  `QT_QPA_PLATFORM=offscreen` environment and drops the isolation.
- This tree defines no `ENABLE_PCH` or unity option and does not call `phosphor_share_test_pch()`. Its tests are two
  small executables. An app's `phosphor_share_test_pch()` call walks every directory below it, so it attaches
  the app's shared test PCH to them too.

## Build and test

```sh
cmake --workflow --preset dev            # configure into build/, build, test
ctest --test-dir build -R <name>         # one test
```

`phosphor-works:build` has the rest: the memory cap, the warning check and the offline archives. The first configure
downloads the pinned phosphor-libs into `.cache/cpm`. CI is the shared C++ CI of the workspace
repository (`cpp-ci.yml`): the `dev` preset on Arch with `QT_QPA_PLATFORM=offscreen`, with a warning failing the
build, a clang-format and qmlformat lint over every tracked file, and the Nix flake. The
shared git hooks (`lefthook.yml`, set up by `lefthook install` or `workspace/tools/setup`) run clang-format and
qmlformat on the staged files and check the commit message.

- `test_components_load` loads every file of the module in a plain engine with the static plugin linked, and with
  `org.phosphor.animation` when phosphor-libs is in the tree. It reads the file list from CMake.
- `test_components_translations` checks that the catalogs resolve, the English plural forms included. It exists only
  when the Qt Linguist tools are found.

## QML

- List every QML file in `_phosphor_components_qml`. The STATIC module, the installed plugin, the `install(FILES)`
  rule, lupdate and `test_components_load` all read that one list. Each file gets `QT_RESOURCE_ALIAS` set to its
  basename so the resource path matches the URI.
- A singleton (`ZoneColorDefaults`) also needs `QT_QML_SINGLETON_TYPE TRUE` on its file.
- Strings use `qsTr()`, so the file name is the context. Do not use `i18n()` here. After a string change, run
  `cmake --build build --target phosphor-components-update-ts` and commit the `.ts` files. `-no-obsolete` drops a
  string that left the QML from every catalog.
- The English catalog is compiled too, for the plural forms of strings that take a count.
- Colors and spacing come from `Kirigami.Theme` and `Kirigami.Units` for now. The design language will restyle them.

## Where things are

| Area | Files |
| --- | --- |
| Layout cards and previews | `LayoutCard.qml`, `ZonePreview.qml`, `ZoneColorDefaults.qml` |
| Badges | `CategoryBadge.qml`, `CapabilityBadgeRow.qml`, `AspectRatioBadge.qml` |
| Popup frame | `PopupFrame.qml` |
| Shader parameter editor | `ParameterEditor.qml`, `ParameterSection.qml`, `ParameterRow.qml`, `ShaderParamsEditor.qml` |
| Shader preview states | `ShaderErrorBanner.qml`, `ShaderPreviewPlaceholder.qml`, `DecorationPreviewCard.qml` |
| Small pieces | `StripEmptyState.qml`, `CategoryMenuButton.qml`, `AxisChevron.qml` |
| Module, catalogs, install | `libs/phosphor-components/CMakeLists.txt` |
| Tests | `libs/phosphor-components/tests/` |
| phosphor-libs pin | `cmake/PhosphorComponentsDependencies.cmake`, `nix/package.nix` |
