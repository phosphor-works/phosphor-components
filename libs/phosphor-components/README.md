<!-- SPDX-FileCopyrightText: 2026 fuddlesworth
     SPDX-License-Identifier: LGPL-2.1-or-later -->

# phosphor-components

> The `Phosphor.Components` QML module: the components the Phosphor apps
> share, from layout cards and zone previews to badges, popup frames and the
> shader parameter editor. Themed with Kirigami for now; the design language
> will restyle them.

## Responsibility

One place for the QML pieces several apps draw. They came from PlasmaZones,
whose overlays, settings app and editor shared them, and they keep its
behaviour.

- **Data in, signals out.** A component takes plain values (a layout's zones
  in relative geometry, a parameter's description and current value) and
  reports the user's actions as signals. It reads no application state of
  its own, so any host can drive it.
- **Hosts inject settings.** `ZoneColorDefaults` resolves the default zone
  colours from the Kirigami palette, and a host with its own settings object
  assigns it to `settingsSource` so previews show the user's colours.
- **Translated by their own catalog.** The strings go through `qsTr()`, so
  each component's file name is its translation context, into
  `translations/phosphor-components_<lang>.ts`. A host installs the catalog
  for its locale (see below).

## Key types

| Type | Purpose |
|------|---------|
| `LayoutCard` | One layout as a card in a grid or list: its zone preview, name, category and state badges. No mouse handling; the parent supplies its own |
| `ZonePreview` | A layout's zones drawn in miniature from their relative geometry, with gaps, numbers, and active, hovered and selected states |
| `ZoneColorDefaults` | Singleton with the default zone fill and border colours; `settingsSource` takes a host's settings object |
| `CategoryBadge`, `CapabilityBadgeRow`, `AspectRatioBadge` | Badges for a layout's category, capabilities and aspect ratio |
| `PopupFrame` | The frame of a popup surface |
| `ParameterEditor`, `ParameterSection`, `ParameterRow`, `ShaderParamsEditor` | The shader parameter editor: grouped, lockable, randomizable parameters with colour and image pickers |
| `ShaderErrorBanner`, `ShaderPreviewPlaceholder`, `DecorationPreviewCard` | Shader preview states and the decoration preview card |
| `StripEmptyState`, `CategoryMenuButton`, `AxisChevron` | Smaller shared pieces |

## Use

An app that builds this tree with its own links the static module and imports
its plugin:

```cmake
target_link_libraries(myapp PRIVATE PhosphorComponents::PhosphorComponentsQml PhosphorComponentsQmlplugin)
```

```cpp
Q_IMPORT_QML_PLUGIN(Phosphor_ComponentsPlugin)
```

An installed build puts the module into Qt's QML directory instead. Either way
QML imports it with `import Phosphor.Components`, and the host loads the
catalog once its QCoreApplication exists:

```cpp
auto* translator = new QTranslator(app);
if (translator->load(QLocale(), QStringLiteral("phosphor-components"), QStringLiteral("_"),
                     QStringLiteral("/usr/share/phosphor-works/translations"))) {
    app->installTranslator(translator);
}
```

The English catalog is compiled too, because it holds the English plural
forms of the strings that take a count. After changing a string, run
`cmake --build build --target phosphor-components-update-ts`.

## Dependencies

- `QtCore`, `QtQml`, `QtQuick`, and the Qt Linguist tools for the catalogs
- At run time: QtQuick.Controls, QtQuick.Layouts, QtQuick.Dialogs,
  `org.kde.kirigami` and `org.phosphor.animation` (phosphor-libs)
