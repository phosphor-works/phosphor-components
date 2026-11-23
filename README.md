# phosphor-components

LGPL QML components the Phosphor apps share: layout cards and zone previews, badges, popup frames, the shader
parameter editor and their smaller pieces, as the `Phosphor.Components` module. PlasmaZones' overlays, settings and
editor use them, and so can Lambent, Facet and the design language's storybook. They build on
[phosphor-libs](https://github.com/phosphor-works/phosphor-libs).

| Library | What it is |
| --- | --- |
| `phosphor-components` | The `Phosphor.Components` QML module and its translation catalog |

The library lives in `libs/phosphor-components/`.

## Build

Needs what phosphor-libs needs (CMake 3.23, 3.25 for the presets below, Qt 6.10 with its private headers,
extra-cmake-modules, Wayland), plus KF6 Kirigami and the Qt Linguist tools. The first configure downloads the
phosphor-libs commit that `cmake/PhosphorComponentsDependencies.cmake` pins, and the archives that commit pins, into
`.cache/cpm`.

```sh
cmake --workflow --preset dev
```

That configures into `build/`, builds phosphor-libs and the module, and runs the tests. To build against a local
phosphor-libs checkout, add `-DCPM_phosphor-libs_SOURCE=/path/to/phosphor-libs` to the configure.

## Use from an app

An app adds phosphor-libs first, then this repository, both with [CPM](https://github.com/cpm-cmake/CPM.cmake) and
pinned to one commit each by archive URL and SHA-256. The app's phosphor-libs pin is then the one in use, and this
tree fetches nothing of its own:

```cmake
CPMAddPackage(NAME phosphor-components
              URL "https://github.com/phosphor-works/phosphor-components/archive/<commit>.tar.gz"
              URL_HASH SHA256=<sha256>)
```

To build the app against a local checkout instead, configure it with
`-DCPM_phosphor-components_SOURCE=/path/to/phosphor-components`.

## License

LGPL-2.1-or-later. See `COPYING.LESSER`.
