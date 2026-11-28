<!-- SPDX-FileCopyrightText: 2026 Phosphor Works Team -->
<!-- SPDX-License-Identifier: LGPL-2.1-or-later -->

# phosphor-style

The `Phosphor.Style` QML module is a Qt Quick Controls style. It draws the controls of Qt with the tokens of
`Phosphor.Design`. Thus an app that uses plain Qt Quick Controls has the appearance of the Phosphor suite. The
storybook in the [design-language](https://github.com/phosphor-works/design-language) repository shows each control
in each state.

## Responsibility

The module has one file for each Qt Quick Controls type that it draws. A type with no file here uses the Basic
style of Qt.

- **A style, not a set of new types.** An app continues to write `Button`, `Switch` and `ComboBox` from
  `QtQuick.Controls`. The style changes how they look and move.
- **Tokens, not values.** Each file reads `Theme`, `Metrics` and `Motion` from `Phosphor.Design`. It contains no
  color, radius, font size, gap or duration.
- **The states are a fixed set.** Hover, pressed, focus, on, current and disabled look the same in each control.
  The keyboard focus is the `FocusRing` of `Phosphor.Design`.

## Key types

| Type | Purpose |
|------|---------|
| `Button`, `ToolButton`, `TabButton`, `TabBar` | The buttons and the tab bar |
| `CheckBox`, `RadioButton`, `Switch`, `Slider`, `ComboBox`, `TextField` | The input controls |
| `Menu`, `MenuItem`, `MenuSeparator`, `ItemDelegate` | A menu and its rows |
| `Popup`, `ToolTip`, `Frame`, `Pane`, `ApplicationWindow` | The surfaces |
| `ScrollBar`, `ScrollIndicator`, `ScrollView` | Scrolling |
| `BusyIndicator`, `ProgressBar`, `Label` | Progress and text |

## Use

An app that builds this tree with its own tree links the two static modules and imports their plugins:

```cmake
target_link_libraries(myapp PRIVATE
    PhosphorStyle::PhosphorStyleQml PhosphorStyleQmlplugin PhosphorDesignQmlplugin)
```

```cpp
Q_IMPORT_QML_PLUGIN(Phosphor_StylePlugin)
Q_IMPORT_QML_PLUGIN(Phosphor_DesignPlugin)
```

The app selects the style before it loads QML:

```cpp
QQuickStyle::setStyle(QStringLiteral("Phosphor.Style"));
```

An installed build puts the module into the QML directory of Qt, where the same call finds it.

A tool can also load the files from this source tree, as the storybook does. Add `libs/phosphor-style/qml` and
`libs/phosphor-design/qml` to the import path of the engine. The `qmldir` in `qml/Phosphor/Style/` lists the types
for this use. When you add a file, add it to that `qmldir` and to `_phosphor_style_qml` in `CMakeLists.txt`. The
configure fails when the two lists differ.

## Dependencies

- `QtCore`, `QtQml`, `QtQuick`, and `phosphor-design`
- At run time: QtQuick.Templates, QtQuick.Controls and `Phosphor.Design`
