<!-- SPDX-FileCopyrightText: 2026 Phosphor Works Team -->
<!-- SPDX-License-Identifier: LGPL-2.1-or-later -->

# phosphor-components

The `Phosphor.Components` QML module holds the components that the Phosphor apps share. These include layout cards,
zone previews, badges, popup frames and the shader parameter editor. Kirigami gives them their theme now. The design
language will change their style.

## Responsibility

The module is one place for the QML parts that several apps draw. The parts came from PlasmaZones, where the
overlays, the settings app and the editor shared them. They keep the behavior that they had in PlasmaZones.

- **Data in, signals out.** A component takes plain values, for example the zones of a layout in relative geometry,
  or the description and current value of a parameter. It reports the actions of the user as signals. It reads no
  application state of its own, so each host can control it.
- **Hosts inject settings.** `ZoneColorDefaults` gets the default zone colors from the Kirigami palette. A host with
  its own settings object assigns that object to `settingsSource`, so the previews show the colors of the user.
- **Translated by their own catalog.** The strings go through `qsTr()`, so the file name of each component is its
  translation context. The strings go into `translations/phosphor-components_<lang>.ts`. A host installs the catalog
  for its locale (see "Use").

## Key types

| Type | Purpose |
|------|---------|
| `LayoutCard` | One layout as a card in a grid or list, with its zone preview, name, category and state badges. It has no mouse handling. The parent supplies its own. |
| `ZonePreview` | The zones of a layout, drawn small from their relative geometry, with gaps, numbers, and active, hovered and selected states |
| `ZoneColorDefaults` | A singleton with the default zone fill and border colors. `settingsSource` takes the settings object of a host. |
| `CategoryBadge`, `CapabilityBadgeRow`, `AspectRatioBadge` | Badges for the category, the capabilities and the aspect ratio of a layout |
| `PopupFrame` | The frame of a popup surface |
| `ParameterEditor`, `ParameterSection`, `ParameterRow`, `ShaderParamsEditor` | The shader parameter editor. It shows parameters in groups, and the user can lock them, give them random values and pick colors and images. |
| `ShaderErrorBanner`, `ShaderPreviewPlaceholder`, `DecorationPreviewCard` | The states of a shader preview, and the decoration preview card |
| `StripEmptyState`, `CategoryMenuButton`, `AxisChevron` | Smaller shared parts |

## Use

An app that builds this tree with its own tree links the static module and imports its plugin:

```cmake
target_link_libraries(myapp PRIVATE PhosphorComponents::PhosphorComponentsQml PhosphorComponentsQmlplugin)
```

```cpp
Q_IMPORT_QML_PLUGIN(Phosphor_ComponentsPlugin)
```

An installed build puts the module into the QML directory of Qt. In both cases, QML imports the module with
`import Phosphor.Components`. The host loads the catalog after its QCoreApplication exists:

```cpp
auto* translator = new QTranslator(app);
if (translator->load(QLocale(), QStringLiteral("phosphor-components"), QStringLiteral("_"),
                     QStringLiteral("/usr/share/phosphor-works/translations"))) {
    app->installTranslator(translator);
}
```

The build also compiles the English catalog, because it holds the English plural forms of the strings that take a
count. After you change a string, run `cmake --build build --target phosphor-components-update-ts`.

## Dependencies

- `QtCore`, `QtQml`, `QtQuick`, and the Qt Linguist tools for the catalogs
- At run time: QtQuick.Controls, QtQuick.Layouts, QtQuick.Dialogs, `org.kde.kirigami` and `org.phosphor.animation`
  (phosphor-libs)
