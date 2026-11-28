<!-- SPDX-FileCopyrightText: 2026 Phosphor Works Team -->
<!-- SPDX-License-Identifier: LGPL-2.1-or-later -->

# phosphor-components

phosphor-components holds the LGPL QML that the Phosphor apps share, as three modules. `Phosphor.Design` has the
tokens and the components of the design language. `Phosphor.Style` is its Qt Quick Controls style.
`Phosphor.Components` has layout cards, zone previews, badges, popup frames and the shader parameter editor, which
the overlays, the settings and the editor of PlasmaZones use. The
[design-language](https://github.com/phosphor-works/design-language) repository is the storybook that shows them.
The modules use [phosphor-libs](https://github.com/phosphor-works/phosphor-libs).

## Libraries

Each library is in `libs/`.

| Library | What it is |
| --- | --- |
| `phosphor-design` | The `Phosphor.Design` QML module: the tokens, the motion types and the components of the design language |
| `phosphor-style` | The `Phosphor.Style` QML module: the Qt Quick Controls style that uses the tokens |
| `phosphor-components` | The `Phosphor.Components` QML module and its translation catalog |

## Build

The build needs the packages that phosphor-libs needs, and also KF6 Kirigami and the Qt Linguist tools:

- CMake 3.23, or 3.25 for the presets below
- Qt 6.10 with its private headers
- extra-cmake-modules
- Wayland

The first configure downloads the phosphor-libs commit that `cmake/PhosphorComponentsDependencies.cmake` pins. It
also downloads the archives that this commit pins. The downloads go into `.cache/cpm`.

```sh
cmake --workflow --preset dev
```

This command configures into `build/`, builds phosphor-libs and the modules, and runs the tests. To build against a
local phosphor-libs checkout, add `-DCPM_phosphor-libs_SOURCE=/path/to/phosphor-libs` to the configure.

## Use from an app

An app adds phosphor-libs first, then this repository. It adds both with [CPM](https://github.com/cpm-cmake/CPM.cmake)
and pins each one to one commit by archive URL and SHA-256. The app's phosphor-libs pin is then the one in use, and
this tree downloads nothing of its own:

```cmake
CPMAddPackage(NAME phosphor-components
              URL "https://github.com/phosphor-works/phosphor-components/archive/<commit>.tar.gz"
              URL_HASH SHA256=<sha256>)
```

To build the app against a local checkout, configure the app with
`-DCPM_phosphor-components_SOURCE=/path/to/phosphor-components`.

The app embeds this tree's libraries as it embeds phosphor-libs': with `PHOSPHOR_EMBED_APP` set, the install holds only
what the app runs, in the app's own directories. See "Use from an app" in the [phosphor-libs
README](https://github.com/phosphor-works/phosphor-libs#use-from-an-app). Every install rule here goes through the
functions of phosphor-libs' `cmake/PhosphorSuite.cmake`. The translation catalogs install to
`share/phosphor-works/translations` either way.

## Contributing

The suite conventions are in the [workspace](https://github.com/phosphor-works/workspace) repository, in
`claude/conventions.md`. `CLAUDE.md` gives the layout and the rules of this repository. `lefthook install` sets up
the Git hooks from `lefthook.yml`. The hooks format the staged files and check the Conventional Commits message.

## License

phosphor-components is licensed under LGPL-2.1-or-later. The license text is in `COPYING.LESSER`.
