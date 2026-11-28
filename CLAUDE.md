<!-- SPDX-FileCopyrightText: 2026 Phosphor Works Team -->
<!-- SPDX-License-Identifier: LGPL-2.1-or-later -->

<!-- BEGIN shared: tools/sync writes this block from workspace/sync/claude-header.md. Change it there. -->
# phosphor-components

This file has two parts. The rules that every phosphor-works repository follows come first, from the conventions of
the workspace repository, imported below. The sections after them belong to this repository only: what it is, its
layout, how to build and test it, and its own rules, code, skills and agents, and links to the other repositories.
A section here does not repeat a convention. When a section and the conventions disagree, change one of them so
that they agree.

The Claude Code tooling comes from the plugins that `.claude/settings.json` enables and `workspace/tools/setup`
installs. The `phosphor-works` plugin has the command guard, the shared skills (`phosphor-works:build`, `debug`,
`code-audit`, `record-lesson`, `new-repo`), the shared reviewers, and the lesson index, which adds the lessons that
fit each prompt.

@../workspace/claude/conventions.md
<!-- END shared -->

## Overview

The QML that the Phosphor apps share, as three modules. There is no C++ library. An app links a module as a static
module, or uses the installed plugin. The tree builds on phosphor-libs.

| Module | What it holds |
| --- | --- |
| `Phosphor.Design` | The tokens (`Theme`, `Metrics`, `Motion`, `Icons`), the motion types and the components of the design language |
| `Phosphor.Style` | A Qt Quick Controls style on `Phosphor.Design`. An app calls `QQuickStyle::setStyle("Phosphor.Style")` to use it |
| `Phosphor.Components` | The components that came from PlasmaZones: layout cards and zone previews, badges, popup frames and the shader parameter editor. They use Kirigami |

The storybook of these modules is the design-language repository. It shows each component in each state. No app
uses `Phosphor.Design` or `Phosphor.Style` at this time.

## Layout

- Each module is one library in `libs/`: `phosphor-design`, `phosphor-style` and `phosphor-components`. A library
  has its QML in `qml/Phosphor/<Module>/`, its tests in `tests/` and its own `README.md` with the type table and
  the host instructions. `phosphor-components` also has its catalogs in `translations/`.
- `qml/Phosphor/Design/` and `qml/Phosphor/Style/` each hold a `qmldir` that a person writes. The storybook loads
  the two modules from those directories, so that a saved file shows without a build. The build does not read it.
- `cmake/PhosphorComponentsQmlModule.cmake` makes the targets of `phosphor-design` and `phosphor-style`.
  `cmake/PhosphorComponentsTesting.cmake` adds a test.
- The root CMakeLists.txt adds phosphor-libs, includes phosphor-libs' `PhosphorSuite.cmake` (for
  `PHOSPHOR_SUITE_DIRECTORY_NAME`), then the three libraries.
- `cmake/PhosphorComponentsDependencies.cmake` pins phosphor-libs. `nix/package.nix` repeats that pin.

### Targets and modules

| Target | What it is |
| --- | --- |
| `PhosphorComponentsQml` (alias `PhosphorComponents::PhosphorComponentsQml`) | The STATIC module, URI `Phosphor.Components`, version 1.0 |
| `PhosphorComponentsQmlplugin` | Its generated static plugin. A host links it and calls `Q_IMPORT_QML_PLUGIN(Phosphor_ComponentsPlugin)` |
| `PhosphorComponentsQmlShared` and `PhosphorComponentsQmlSharedplugin` | The same module as a plugin installed to `${KDE_INSTALL_QMLDIR}/Phosphor/Components`, built when `PHOSPHOR_COMPONENTS_QML_INSTALL` is ON (the default) |
| `PhosphorDesignQml` (alias `PhosphorDesign::PhosphorDesignQml`) and `PhosphorDesignQmlplugin` | The STATIC module `Phosphor.Design` and its plugin. A host calls `Q_IMPORT_QML_PLUGIN(Phosphor_DesignPlugin)` |
| `PhosphorStyleQml` (alias `PhosphorStyle::PhosphorStyleQml`) and `PhosphorStyleQmlplugin` | The STATIC module `Phosphor.Style` and its plugin (`Phosphor_StylePlugin`). It links `PhosphorDesignQml`. A host also links `PhosphorDesignQmlplugin` |
| `PhosphorDesignQmlShared`, `PhosphorStyleQmlShared` and their `plugin` targets | The two modules as plugins installed to `${KDE_INSTALL_QMLDIR}/Phosphor/Design` and `.../Style`, built when `PHOSPHOR_COMPONENTS_QML_INSTALL` is ON |
| `phosphor_components_translations` | The compiled catalogs, installed to `share/phosphor-works/translations` |
| `phosphor-components-update-ts` | Runs `lupdate -no-obsolete` over the module's QML into every `.ts` |

There is no C++ namespace, public header, include path or export macro. The module has QML files only.

## Build and test

```sh
cmake --workflow --preset dev            # configure into build/, build, test
ctest --test-dir build -R <name>         # one test
```

`phosphor-works:build` has the rest: the memory cap, the warning check and the offline archives. The first configure
downloads the pinned phosphor-libs into `.cache/cpm`. CI is the shared C++ CI of the workspace
repository (`cpp-ci.yml`): the `dev` preset on Arch and on Fedora 44, with `QT_QPA_PLATFORM=offscreen`, and the Nix flake.

- `test_components_load` loads every file of the module in a plain engine with the static plugin linked, and with
  `org.phosphor.animation` when phosphor-libs is in the tree. It reads the file list from CMake.
- `test_design_load` and `test_style_load` do the same for `Phosphor.Design` and `Phosphor.Style`. They also fail on
  a QML warning, for example a name that does not exist. A token that does not exist gives no warning where the
  property is a color, so these tests do not find it.
- These tests show that a type loads. They do not show its appearance. Render its stories in the design-language
  repository, in the two schemes, before you complete a change to `Phosphor.Design` or `Phosphor.Style`.
- `test_components_translations` checks that the catalogs resolve, the English plural forms included. It exists only
  when the Qt Linguist tools are found.

## Rules

### Layers

- phosphor-libs is the only suite dependency, and only at run time: the files of `Phosphor.Components` import
  `org.phosphor.animation`. Each module links Qt Qml and Quick only. `Phosphor.Components` also imports
  QtQuick.Controls, QtQuick.Layouts, QtQuick.Dialogs and `org.kde.kirigami`, which the host engine resolves.
- **`Phosphor.Design` and `Phosphor.Style` use only Qt.** A file there imports `QtQuick`, `QtQuick.Templates`,
  `QtQuick.Shapes`, `QtQuick.Effects`, `QtQuick.Controls.impl` and these two modules. It does not import a phosphor
  library, Kirigami or a KDE Framework. Thus the storybook can load the two modules with only Qt.
- **`Phosphor.Design` does not import `QtQuick.Controls`.** Controls loads the style, and the style imports
  `Phosphor.Design`. Thus that import is a loop. For a button in a component, use `QtQuick.Templates`.
- Nothing here links or imports phosphor-shell-libs, phosphor-engine-libs or an app. A component takes plain values
  and reports user actions as signals. It reads no app state. A host injects settings, as `ZoneColorDefaults`
  takes a host object through `settingsSource`.

### Tokens

These rules are for `Phosphor.Design` and `Phosphor.Style`.

- **Use only tokens.** A component reads `Theme`, `Metrics` and `Motion`. It contains no color, radius, font size,
  gap or duration. If a token is missing, add the token. The one exception is a dimension of the component itself.
  For example, a switch is 44 by 26. Keep such a dimension in the component.
- **Each component has a story, and each state has a variant.** The stories are in the design-language repository.
  A component without a story is not complete. A change to a token also changes its guide page there.
- **Do not write compatibility code.** No app uses the two modules. Rename a token or a component directly, and
  change its users in the same commit.

### The design language

The Foundations stories of the design-language repository contain the full guide. Review a component of
`Phosphor.Design` or `Phosphor.Style` against these rules.

- **Color shows a state.** A surface is dark and does not move. Use color only for focus, selection, activity or
  an error. The accent is one of the four brand colors. Cyan always shows focus (`FocusRing`, the focused window,
  a cursor). Rose shows an error, a destructive action or an unread item. Use the spectrum only in `Visualizer`,
  on the edge of `ShellBody` and in the logos.
- **An accent fill uses `Theme.ink`.** When a small control is on, its fill is the accent. The current row of a
  list has the `Theme.selected` tint and keeps `Theme.text`.
- **Space is one ramp.** Each gap, inset and margin is a step of `Metrics.spaceRamp`. Use the name when a name
  applies: `gap`, `gapLoose`, `gapSection`, `pad`, `padCard`, `padControl`, `padRow`, `iconGap`, `pageMargin`.
  Related items are near each other. Use space between groups. Use a line only between rows in one card.
- **There are six text sizes and two weights.** The sizes are `textCaption`, `textLabel`, `textBody`, `textRow`,
  `textHeading` and `textTitle`. The weights are 500 and 600. Use sentence case. Do not use uppercase labels or
  letter spacing. `textDisplay` is a seventh size, and only the clock of the lock screen uses it.
- **The states are a fixed set.** Hover is `Theme.hover`. Pressed is `Metrics.pressScale` and not a color. Focus
  is `FocusRing`. On is the accent with ink. Current is `Theme.selected`. Disabled is `Theme.disabled`.
- **A panel opens from its control.** A shell panel opens from the control that the user pressed, and closes into
  it. Use `ShellBody`. Do not use a popup next to the bar.
- **A detail is a page of the same panel.** A Wi-Fi list and the menu of a tray app are pages (`PanelPage`) of the
  panel that the user opened. The details of a resource are an open row. The panel changes size. A second popup
  does not open.
- **A panel has one header or none.** The header (`PanelHeader`) is the name of the page and its main control. A
  first page that needs no name has no header. Do not write a line above the name or a sentence below it.
- **Empty is a state.** Show it with one dim icon in the position of the content. Do not write a sentence.
- **A palette replaces roles, not components.** A preset or a wallpaper sets `Theme.palette` with the role names of
  matugen. A component reads only `Theme`, so it needs no change for a new palette.
- **The shell has a material.** A surface of the shell uses `Theme.shellSurface`, which is glass or solid
  (`Theme.material`). A window of an app uses `Theme.surface` and is always solid. Do not put an opacity on a
  surface in a component.
- **Springs move, fades color.** A position, a size, a radius or a scale moves on `SnapSpring`, `FlowSpring` or
  `TrailSpring`. A color uses `Tint`, and an opacity uses `Fade`. Do not use a `NumberAnimation` with a duration on
  geometry.
- **Name, value or action.** Each string gives the name of an item, shows a value or tells what a control does.
  Do not write an eyebrow above a title, a tagline, a helper sentence below a control, or a status sentence. Use
  an icon when the icon gives the same information. Put an explanation in a tooltip.
- **Show the state.** Use a fill level, a position or a shape. Do not write a sentence that describes the state.
- **The user sets three values of shape.** The corner radius (`Metrics.corners`), the density (`Metrics.density`)
  and the space between windows (`Metrics.spread`) are inputs. Each radius, height and gap follows them. A preset
  sets them together with a palette.
- **Shape uses `Metrics`.** An inner radius is the outer radius minus the padding. A control that is on is
  rounder.

### License

Every file, tests included, is `LGPL-2.1-or-later`. The components came from PlasmaZones (GPL). Code that moves in
from an app is a relicense (see the conventions).

## Code

### QML

- List every QML file in `_phosphor_components_qml`. The STATIC module, the installed plugin, the `install(FILES)`
  rule, lupdate and `test_components_load` all read that one list. Each file gets `QT_RESOURCE_ALIAS` set to its
  basename so the resource path matches the URI.
- A file of `Phosphor.Design` or `Phosphor.Style` goes into two lists: `_phosphor_design_qml` or
  `_phosphor_style_qml` in the library's CMakeLists.txt, and the `qmldir` beside the file. A singleton also goes
  into `SINGLETONS` and has `singleton` in the `qmldir`. The configure fails when the two lists differ.
- In `Phosphor.Design` and `Phosphor.Style`, a property or a function that is not API starts with `_`. A control
  that shows no text sets `Accessible.name`. A control shows `FocusRing` for keyboard focus. The comment at the top
  of a component tells its purpose and its use.
- `icon` is a final property of the Qt Quick Controls button template. A `T.AbstractButton` that declares
  `property string icon` does not load. Use a different name, for example `iconName`.
- A singleton (`ZoneColorDefaults`) also needs `QT_QML_SINGLETON_TYPE TRUE` on its file.
- Strings use `qsTr()`, so the file name is the context. Do not use `i18n()` here. After a string change, run
  `cmake --build build --target phosphor-components-update-ts` and commit the `.ts` files. `-no-obsolete` drops a
  string that left the QML from every catalog.
- `Phosphor.Design` has eight `qsTr()` strings and no catalog yet. That update target reads only
  `Phosphor.Components`.
- The English catalog is compiled too, for the plural forms of strings that take a count.
- In `Phosphor.Components`, colors and spacing come from `Kirigami.Theme` and `Kirigami.Units` for now. The tokens
  of `Phosphor.Design` will replace them.

## Other repositories

### How apps consume it

- PlasmaZones pins one commit in `cmake/PlasmaZonesDependencies.cmake` and repeats it in
  `packaging/nix/package.nix`. `plasmazones_add_phosphor_components()` adds this tree with CPM after phosphor-libs
  and forces `PHOSPHOR_COMPONENTS_QML_INSTALL` OFF, because the app links the static module.
- Build an app against a local checkout with `-DCPM_phosphor-components_SOURCE=<dir>`, or use the workspace
  superbuild (`cmake --workflow --preset plasmazones` in `../workspace`), which sets that for every library.
- After a change merges here, move the app's pin: VERSION, URL, FILE and SHA256 together, in both files.
- A host loads the `phosphor-components` catalog itself with a `QTranslator` (PlasmaZones does it in
  `translationloader.cpp`). The library's `README.md` has the snippet.

### The storybook

- The design-language repository is the storybook of `Phosphor.Design` and `Phosphor.Style`. It pins one commit of
  this repository and loads the two modules from the `qml/` directories of that tree. With a checkout of this
  repository beside it, its `local` preset loads the files of the checkout, and a saved file shows at once.
- After a change to the two modules merges here, move the pin there and change the stories in the same pull request.
- branding: the canonical palette is `palette/phosphor.toml` in phosphor-works/branding. `Theme.qml` holds a copy of
  its values in `palettes`. Whether a pinned branding release must generate them is not decided. Ask before you
  change how the tokens relate to that palette.
- phosphor-shell-libs makes the real shell surfaces and has its own tokens in phosphor-theme. The Paper preset and
  the Ember preset of the storybook are the values of phosphor-theme.
- phosphor-libs has `PhosphorMotionAnimation`, which installs a spring as a Bézier approximation with a fixed
  duration. `Phosphor.Design` uses `SpringAnimation`, because a spring here must accept a new target during a move.

### As a subproject

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

## Where things are

| Area | Files |
| --- | --- |
| Color tokens | `libs/phosphor-design/qml/Phosphor/Design/Theme.qml`: the two schemes in `palettes`, the roles, the state colors, `contrast()` |
| Space, size, shape and type tokens | `Metrics.qml` in that directory: the space ramp, the sizes, the radii, the lines, the type scale |
| Motion tokens | `Motion.qml` in that directory, and the types `SnapSpring`, `FlowSpring`, `TrailSpring`, `Fade` and `Tint` |
| Icons | `Icons.qml` in that directory: the icons as path data |
| Design components | The other files of `libs/phosphor-design/qml/Phosphor/Design/`, in the list of its `qmldir` |
| Controls style | `libs/phosphor-style/qml/Phosphor/Style/*.qml`, one file for each Qt Quick Controls type. A type with no file uses the Basic style |
| Targets of the two modules | `cmake/PhosphorComponentsQmlModule.cmake`, `libs/phosphor-design/CMakeLists.txt`, `libs/phosphor-style/CMakeLists.txt` |
| Layout cards and previews | `LayoutCard.qml`, `ZonePreview.qml`, `ZoneColorDefaults.qml` |
| Badges | `CategoryBadge.qml`, `CapabilityBadgeRow.qml`, `AspectRatioBadge.qml` |
| Popup frame | `PopupFrame.qml` |
| Shader parameter editor | `ParameterEditor.qml`, `ParameterSection.qml`, `ParameterRow.qml`, `ShaderParamsEditor.qml` |
| Shader preview states | `ShaderErrorBanner.qml`, `ShaderPreviewPlaceholder.qml`, `DecorationPreviewCard.qml` |
| Small pieces | `StripEmptyState.qml`, `CategoryMenuButton.qml`, `AxisChevron.qml` |
| Module, catalogs, install | `libs/phosphor-components/CMakeLists.txt` |
| Tests | `libs/<library>/tests/`, and `cmake/PhosphorComponentsTesting.cmake` |
| phosphor-libs pin | `cmake/PhosphorComponentsDependencies.cmake`, `nix/package.nix` |
