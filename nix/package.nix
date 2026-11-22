# SPDX-FileCopyrightText: 2026 fuddlesworth
# SPDX-License-Identifier: LGPL-2.1-or-later
#
# The phosphor-components package: the Phosphor.Components QML module and its
# catalogs, built with the phosphor-libs commit
# cmake/PhosphorComponentsDependencies.cmake pins, whose libraries the package
# includes. `withTests` builds and runs the test suite (phosphor-libs'
# included) in the sandbox, which is what the flake's `checks.<system>.tests`
# does.
{
  lib,
  stdenv,
  fetchurl,
  linkFarm,
  cmake,
  ninja,
  pkg-config,
  qt6,
  kdePackages,
  wayland,
  wayland-scanner,
  vulkan-headers,
  dbus,
  src,
  version,
  withTests ? false,
}:

let
  # The pinned phosphor-libs commit (cmake/PhosphorComponentsDependencies.cmake)
  # and the archives that commit pins in its cmake/PhosphorDependencies.cmake:
  # Luau and jsoncons, and the surface packs its test suite reads. The sandbox
  # has no network, so they are fetched here as fixed-output derivations and
  # handed to CMake as one directory (PHOSPHOR_DEPS_ARCHIVES), each under the
  # FILE name its pin gives it. CMake checks each against the pin's hash again
  # before unpacking it. fetchurl, not fetchFromGitHub: the pin hashes the
  # archive file itself.
  depsArchives = linkFarm "phosphor-components-deps-archives" [
    {
      name = "phosphor-libs-e6e4322929b103b3dd08febd51a2a616c477187b.tar.gz";
      path = fetchurl {
        url = "https://github.com/phosphor-works/phosphor-libs/archive/e6e4322929b103b3dd08febd51a2a616c477187b.tar.gz";
        # sha256 508b16cb46a133b9bc1d9d3c48c7793df78441a1bbcf19dda68274a2823d9ae6
        hash = "sha256-UIsWy0ahM7m8HZ08SMd5PfeEQaG7zxndpoJ0ooI9muY=";
      };
    }
    {
      name = "luau-0.745.tar.gz";
      path = fetchurl {
        url = "https://github.com/luau-lang/luau/archive/refs/tags/0.745.tar.gz";
        # sha256 53c22773bace6cabbabaead576fbc08d11a0317fce11a3dbf9d027dda6849248
        hash = "sha256-U8Inc7rObKu6uurVdvvAjRGgMX/OEaPb+dAn3aaEkkg=";
      };
    }
    {
      name = "jsoncons-1.10.0.tar.gz";
      path = fetchurl {
        url = "https://github.com/danielaparker/jsoncons/archive/refs/tags/v1.10.0.tar.gz";
        # sha256 c829350a2eece662beb378143e2ab1c1cbb07d703687bf168626665a8a7d8bc1
        hash = "sha256-yCk1Ci7s5mK+s3gUPiqxwcuwfXA2h78WhiZmWop9i8E=";
      };
    }
    {
      name = "phosphor-surface-packs-087bd740eb0650b5a4256566663d8332d00c7cd7.tar.gz";
      path = fetchurl {
        url = "https://github.com/phosphor-works/phosphor-surface-packs/archive/087bd740eb0650b5a4256566663d8332d00c7cd7.tar.gz";
        # sha256 2b3244bbd1d198cc9361dea105b01bfbcd32bbe35843ddd392881208370b40e1
        hash = "sha256-KzJEu9HRmMyTYd6hBbAb+80yu+NYQ93TkogSCDcLQOE=";
      };
    }
  ];
in
stdenv.mkDerivation {
  pname = if withTests then "phosphor-components-tests" else "phosphor-components";
  inherit version src;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    kdePackages.extra-cmake-modules
    wayland-scanner
    # lupdate and lrelease, for the catalogs.
    qt6.qttools
    # Its environment hook collects every Qt input's plugin and QML directories
    # (QtQuick, Controls, Kirigami, each in its own store path) into
    # qtWrapperArgs, which preCheck turns into the test environment.
    qt6.wrapQtAppsHook
  ];

  # A QML module and libraries, no applications to wrap.
  dontWrapQtApps = true;

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtshadertools
    qt6.qtsvg
    qt6.qtwayland
    wayland
    # Qt declares QVulkanInstance only with the Vulkan headers present, and
    # phosphor-surfaces uses it when Qt has Vulkan, as nixpkgs' Qt does.
    vulkan-headers
    # The components draw through Kirigami.
    kdePackages.kirigami
    # phosphor-libs' optional lookups, so it builds the code they switch on.
    kdePackages.kglobalaccel
    kdePackages.plasma-activities
  ];

  # dbus-run-session gives each test a private session bus
  # (phosphor-libs' cmake/PhosphorTestIsolation.cmake).
  nativeCheckInputs = [ dbus ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_TESTING=${if withTests then "ON" else "OFF"}"
    "-DPHOSPHOR_DEPS_ARCHIVES=${depsArchives}"
    "-DKDE_INSTALL_QTPLUGINDIR=${placeholder "out"}/${qt6.qtbase.qtPluginPrefix}"
    "-DKDE_INSTALL_QMLDIR=${placeholder "out"}/${qt6.qtbase.qtQmlPrefix}"
  ];

  doCheck = withTests;
  # The tests run uninstalled, from the build tree, so nothing wraps them.
  # nixpkgs' Qt finds QML modules through NIXPKGS_QT6_QML_IMPORT_PATH and
  # plugins through QT_PLUGIN_PATH, and wrapQtAppsHook puts both only into the
  # wrapper arguments of installed programs. Export the same entries here, so
  # the tests that load QtQuick, Controls or Kirigami find them. Then the
  # offscreen platform for the GUI tests, and a writable HOME for the ones the
  # XDG sandbox does not cover.
  preCheck = ''
    for ((i = 0; i + 3 < ''${#qtWrapperArgs[@]}; i++)); do
      if [[ "''${qtWrapperArgs[i]}" == --prefix ]]; then
        case "''${qtWrapperArgs[i + 1]}" in
          NIXPKGS_QT6_QML_IMPORT_PATH | QT_PLUGIN_PATH)
            addToSearchPath "''${qtWrapperArgs[i + 1]}" "''${qtWrapperArgs[i + 3]}"
            ;;
        esac
      fi
    done
    export NIXPKGS_QT6_QML_IMPORT_PATH QT_PLUGIN_PATH
    export QT_QPA_PLATFORM=offscreen
    export HOME="$(mktemp -d)"
    export CTEST_OUTPUT_ON_FAILURE=1
  '';

  meta = {
    description = "QML components shared by the Phosphor apps";
    homepage = "https://github.com/phosphor-works/phosphor-components";
    license = with lib.licenses; [
      lgpl21Plus
      mit
      boost
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
