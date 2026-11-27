<!-- SPDX-FileCopyrightText: 2026 Phosphor Works Team -->
<!-- SPDX-License-Identifier: LGPL-2.1-or-later -->

# Changelog

This file records each release of phosphor-components, the shared QML components.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). The versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html), as the phosphor-works conventions say.

## [Unreleased]

### Added

- An app can embed the libraries (phosphor-libs' `PHOSPHOR_EMBED_APP`): the install then holds only the shared
  libraries that the app's programs link, in the app's own directory. Every install rule goes through the functions of
  phosphor-libs' `cmake/PhosphorSuite.cmake`.

### Changed

- The libraries' tests build only in this repository's own build, or in a library configured on its own. An app or
  the workspace superbuild that adds the tree with `BUILD_TESTING` on no longer builds them.
- Builds on phosphor-libs `bf8bf88b`, which installs the licence notices of the Wayland protocols that
  phosphor-wayland compiles in (phosphor-works/PlasmaZones#1193).

## [0.1.0] - 2026-11-26

The first release. It has 1 library: `phosphor-components`. The tag `v0.1.0` is commit `0f3e7291`, which PlasmaZones pins.

[Unreleased]: https://github.com/phosphor-works/phosphor-components/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/phosphor-works/phosphor-components/releases/tag/v0.1.0
