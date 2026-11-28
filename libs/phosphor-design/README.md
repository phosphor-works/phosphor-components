<!-- SPDX-FileCopyrightText: 2026 Phosphor Works Team -->
<!-- SPDX-License-Identifier: LGPL-2.1-or-later -->

# phosphor-design

The `Phosphor.Design` QML module holds the design language of the Phosphor suite. It has the tokens, the motion
types and the components that Qt Quick Controls does not have. It uses only Qt. The storybook in the
[design-language](https://github.com/phosphor-works/design-language) repository shows each type in each state.

## Responsibility

The module gives one appearance and one motion to each Phosphor app.

- **Tokens, not values.** A component reads `Theme`, `Metrics` and `Motion`. It contains no color, radius, font
  size, gap or duration. A palette or a preset changes the tokens, and each component follows.
- **Springs move, fades color.** A position, a size or a shape moves on `SnapSpring`, `FlowSpring` or
  `TrailSpring`. A color uses `Tint`, and an opacity uses `Fade`.
- **Data in, signals out.** A component takes plain values and reports the actions of the user as signals. It
  reads no application state.
- **Only Qt.** The files import no phosphor library and no KDE Framework, so a tool can load them from the source
  tree with only Qt.

## Key types

| Type | Purpose |
|------|---------|
| `Theme` | A singleton with the colors: the two schemes, the roles, the state colors, the accent and the material of the shell |
| `Metrics` | A singleton with space, size, shape and type: the space ramp, the radii, the heights and the type scale |
| `Motion` | A singleton with the values of the springs and the fades |
| `SnapSpring`, `FlowSpring`, `TrailSpring`, `Fade`, `Tint` | The motion types. A component puts one in a `Behavior` |
| `Icons`, `Icon` | The set of symbolic icons as path data, and the item that draws one |
| `FocusRing`, `StretchIndicator` | The keyboard focus ring, and the selection indicator of each list, tab bar and segmented control |
| `ShellBody`, `Surface`, `PanelPage`, `PanelHeader` | The bar and its open panel as one shape, a shell surface that does not touch the bar, and the pages of a panel |
| `BarChip`, `WorkspaceStrip`, `Tile`, `BigSlider`, `NotificationCard` | The controls of the bar and of the shell panels |
| `NavList`, `ListRow`, `SettingGroup`, `SettingRow`, `Segmented`, `SwatchPicker` | The sidebar list, a list row, the settings rows and the small choice controls |
| `IconButton`, `Badge`, `Avatar`, `Keycap`, `Meter`, `Sparkline`, `Spinner`, `Bars`, `Visualizer` | Small parts that show an action, a state or a value |
| `Artwork`, `MonthGrid`, `LayoutPreview`, `WindowFrame` | A picture with round corners, one month, the windows of one workspace, and the window of a Phosphor app |

## Use

An app that builds this tree with its own tree links the static module and imports its plugin:

```cmake
target_link_libraries(myapp PRIVATE PhosphorDesign::PhosphorDesignQml PhosphorDesignQmlplugin)
```

```cpp
Q_IMPORT_QML_PLUGIN(Phosphor_DesignPlugin)
```

An installed build puts the module into the QML directory of Qt. In both cases, QML imports the module with
`import Phosphor.Design`.

A tool can also load the files from this source tree, as the storybook does. Add
`libs/phosphor-design/qml` to the import path of the engine. The `qmldir` in `qml/Phosphor/Design/` lists the types
for this use. When you add a file, add it to that `qmldir` and to `_phosphor_design_qml` in `CMakeLists.txt`. The
configure fails when the two lists differ.

Eight strings go through `qsTr()`. The module has no catalog yet, so they show in English.

## Dependencies

- `QtCore`, `QtQml`, `QtQuick`
- At run time: QtQuick.Templates, QtQuick.Shapes and QtQuick.Effects
