// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

pragma Singleton

import QtQuick

// Color. A surface is dark and does not move. Color shows a state.
//
// A component reads the roles below and does not contain a color value. The values are in
// `palettes`, one table for each scheme. Thus the guide can show the two schemes, and a component
// does not know its scheme. The brand colors are the colors in branding/palette/phosphor.toml.
QtObject {
    id: theme

    // ── Inputs: an app or a settings page writes these ──────────────────────
    property string scheme: "dark" // "dark" or "light"
    property string accentName: "blue" // "blue", "cyan", "purple" or "rose"
    property bool glow: true
    // The material of the shell: "solid", or "glass". Glass lets a small part of the desktop show
    // through the bar and its panels. The compositor adds the blur. A window of an app is solid.
    property string material: "glass"

    // A palette with the role names of matugen (background, surface, primary, on_surface). A role
    // in this palette replaces the brand value. A palette from a wallpaper gets to each component
    // in this way. The default is empty.
    property var palette: ({})

    readonly property bool dark: scheme !== "light"

    // ── The two schemes ─────────────────────────────────────────────────────
    // In the light scheme each brand color is darker. White ink on an accent fill then has a
    // contrast of 4.5 to 1 or more. A color with alpha has the format #AARRGGBB.
    readonly property var palettes: ({
            "dark": {
                "cyan": "#22D3EE",
                "blue": "#3B82F6",
                "purple": "#A855F7",
                "rose": "#F43F5E",
                "green": "#34D399",
                "amber": "#FBBF24",
                "desktop": "#050916",
                "sidebar": "#060C1B",
                "surface": "#070F22",
                "card": "#0B1730",
                "field": "#101A36",
                "track": "#18244A",
                "text": "#E6EDFF",
                "muted": "#94A3B8",
                "ink": "#050916",
                "line": "#2494A3B8",
                "hover": "#12E6EDFF",
                "shade": "#80000000"
            },
            "light": {
                "cyan": "#0E7490",
                "blue": "#2563EB",
                "purple": "#9333EA",
                "rose": "#E11D48",
                "green": "#059669",
                "amber": "#B45309",
                "desktop": "#DDE4EF",
                "sidebar": "#EEF2F8",
                "surface": "#F8FAFC",
                "card": "#FFFFFF",
                "field": "#EAEFF7",
                "track": "#D3DCEA",
                "text": "#0B1730",
                "muted": "#4B5A75",
                "ink": "#FFFFFF",
                "line": "#210B1730",
                "hover": "#0F0B1730",
                "shade": "#330B1730"
            }
        })
    readonly property var _now: palettes[dark ? "dark" : "light"]

    // ── Light: the four brand stops, and two that only ever mean a result ───
    readonly property color cyan: _now.cyan
    readonly property color blue: _now.blue
    readonly property color purple: _now.purple
    readonly property color rose: _now.rose
    readonly property color green: _now.green
    readonly property color amber: _now.amber

    // The spectrum is the brand and does not show a state. Use it only on the edge of the shell
    // body and in the logos. It is the same in the two schemes.
    readonly property list<color> spectrum: [_role("brand_stop_0", "#22D3EE"), _role("brand_stop_1", "#3B82F6"), _role("brand_stop_2", "#A855F7"), _role("brand_stop_3", "#F43F5E")]

    // ── Grounds, from the back forward ──────────────────────────────────────
    readonly property color desktop: _role("background", _now.desktop) // behind everything
    readonly property color sidebar: _role("surface_container_low", _now.sidebar) // navigation columns
    readonly property color surface: _role("surface_container", _now.surface) // windows
    readonly property real glassOpacity: 0.93
    readonly property color shellSurface: tint(surface, material === "glass" ? glassOpacity : 1) // the shell body, panels
    readonly property color card: _role("surface", _now.card) // a group of rows on a window
    readonly property color field: _role("surface_container_high", _now.field) // fields, resting buttons
    readonly property color track: _role("surface_container_highest", _now.track) // the unlit part of a control

    // ── Roles ───────────────────────────────────────────────────────────────
    readonly property color accent: _role("primary", ({
            "blue": blue,
            "cyan": cyan,
            "purple": purple,
            "rose": rose
        })[accentName] ?? blue)
    readonly property color focus: cyan // keyboard focus, the focused window, the cursor
    readonly property color danger: rose // errors, destructive actions, unread
    readonly property color success: green // a result that went well, and nothing else
    readonly property color warning: amber // a state that needs a look: caps lock, low battery

    readonly property color text: _role("on_surface", _now.text) // names and values
    readonly property color muted: _role("on_surface_variant", _now.muted) // secondary values, idle icons
    readonly property color ink: _role("on_primary", _now.ink) // text and icons on a lit fill

    // ── States ──────────────────────────────────────────────────────────────
    readonly property color line: _now.line // a 1 px edge between two grounds
    readonly property color hover: _now.hover // laid over whatever is under the pointer
    readonly property color shade: _now.shade // behind a modal surface
    readonly property real selectedAlpha: 0.2
    readonly property color selected: tint(accent, selectedAlpha) // the current row of a list
    readonly property real disabled: 0.5 // the opacity of a control that cannot be used

    // The same color with a different opacity: the plate of an icon, a measurement band.
    function tint(c: color, alpha: real): color {
        return Qt.rgba(c.r, c.g, c.b, alpha);
    }

    // The WCAG contrast ratio of two opaque colors, from 1 to 21. Text must have 4.5. The edge of a
    // control must have 3.
    function contrast(a: color, b: color): real {
        const channel = v => v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
        const luminance = c => 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
        const la = luminance(a), lb = luminance(b);
        return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
    }

    function _role(name: string, fallback: color): color {
        const value = palette[name];
        return value !== undefined ? value : fallback;
    }
}
