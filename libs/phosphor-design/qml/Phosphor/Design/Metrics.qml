// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

pragma Singleton

import QtQuick

// Space, size, shape and type. Each distance in a component is one of these values.
QtObject {
    // ── Inputs ──────────────────────────────────────────────────────────────
    property real corners: 16 // the bar's radius; every other radius follows it
    property string density: "comfortable" // or "compact"
    property int spread: 10 // the space between two windows, and between a window and the bar

    readonly property bool compact: density === "compact"

    // ── Space: the ramp ─────────────────────────────────────────────────────
    // Each gap, inset and margin is a step of this ramp. A distance that is not on the ramp is an
    // error. The exception is a dimension of one component, for example the travel of a switch.
    // Keep such a dimension in that component.
    readonly property int space2: 2
    readonly property int space4: 4
    readonly property int space6: 6
    readonly property int space8: 8
    readonly property int space10: 10
    readonly property int space12: 12
    readonly property int space16: 16
    readonly property int space20: 20
    readonly property int space24: 24
    readonly property int space32: 32
    readonly property int space48: 48
    readonly property list<int> spaceRamp: [2, 4, 6, 8, 10, 12, 16, 20, 24, 32, 48]

    // ── Space: what the steps are for ───────────────────────────────────────
    // Use these names. Use a step directly only inside one component.
    readonly property int gap: space8 // between siblings: tiles, buttons, cards in a list
    readonly property int gapLoose: space12 // between groups: cards on a page
    readonly property int gapSection: space24 // between the sections of a page
    readonly property int pad: space12 // from the edge of a surface to its content
    readonly property int padCard: space16 // from the side of a card to its rows
    readonly property int padControl: space12 // from the side of a control to its label
    readonly property int padRow: space10 // from the side of a list row to its icon
    readonly property int iconGap: space10 // between an icon and the text it belongs to
    readonly property int pageMargin: space24 // from the edge of a window to its content
    readonly property int screenInset: spread + space2 // from the edge of the screen to the bar
    readonly property int surfaceGap: spread // between two surfaces that do not touch

    // ── Size ────────────────────────────────────────────────────────────────
    readonly property int barHeight: compact ? 36 : 44
    readonly property int controlHeight: compact ? 26 : 30 // buttons, segmented controls
    readonly property int fieldHeight: compact ? 34 : 40 // text fields
    readonly property int rowHeight: compact ? 42 : 50 // a setting: label on one side, control on the other
    readonly property int listRowHeight: compact ? 38 : 44 // something you pick from a list
    readonly property int navRowHeight: compact ? 28 : 32 // a page in a sidebar
    readonly property int tileHeight: compact ? 46 : 54
    readonly property int targetMin: 28 // nothing you can press is smaller than this
    readonly property int sidebarWidth: 236
    readonly property int pageWidth: 640 // the widest a column of settings grows
    readonly property int readingWidth: 620 // the widest a paragraph grows
    readonly property int navIndent: space16 // one step in, for a page under a category

    readonly property int iconSmall: 16 // inside a control or a row of settings
    readonly property int iconSize: 18 // the bar, tiles, shell lists
    readonly property int iconLarge: 22 // a mark, an empty state

    // ── Shape ───────────────────────────────────────────────────────────────
    // An inner radius is the outer radius minus the padding. Thus the steps are 6 (inner), 10
    // (control), 14 (card, window) and 20 (surface).
    readonly property real scale: corners / 16
    readonly property real radiusInner: 6 * scale
    readonly property real radiusControl: 10 * scale
    readonly property real radiusCard: 14 * scale
    readonly property real radiusSurface: 20 * scale

    readonly property real lineWidth: 1 // the edge between two grounds
    readonly property real focusWidth: 2 // the focus ring
    readonly property real focusOffset: 3 // the ring stands this far off the control
    readonly property real iconStroke: 1.7 // on the 24 unit icon grid
    readonly property real rimWidth: 1.2 // the spectrum edge of the shell body

    // The scale of a control while the pointer presses it.
    readonly property real pressScale: 0.94
    readonly property real pressScaleSmall: 0.9 // for a target near the minimum size

    // ── Type ────────────────────────────────────────────────────────────────
    // Six sizes and two weights. Each size has its line height.
    readonly property string fontUi: _firstInstalled(["Manrope", "Inter", "Noto Sans"], Qt.application.font.family)
    readonly property string fontMono: _firstInstalled(["JetBrains Mono", "Hack", "DejaVu Sans Mono", "Noto Sans Mono"], "monospace")

    readonly property int textCaption: 11 // a category in a list, a time stamp
    readonly property int textLabel: 12 // inside a compact control: a segment, a tab, a key
    readonly property int textBody: 13 // the default: settings, buttons, messages
    readonly property int textRow: 14 // what you read to choose: list rows, fields
    readonly property int textHeading: 15 // the name of a thing that owns a surface
    readonly property int textTitle: 22 // the name of a page
    readonly property int textDisplay: 88 // the clock of the lock screen, and no other text

    readonly property int lineCaption: 14
    readonly property int lineLabel: 16
    readonly property int lineBody: 18
    readonly property int lineRow: 20
    readonly property int lineHeading: 20
    readonly property int lineTitle: 28
    readonly property int lineDisplay: 96

    readonly property int weightBody: Font.Medium // 500: running text and values
    readonly property int weightStrong: Font.DemiBold // 600: names, and anything you can press

    function _firstInstalled(names: list<string>, fallback: string): string {
        const installed = Qt.fontFamilies();
        for (const name of names) {
            if (installed.indexOf(name) >= 0)
                return name;
        }
        return fallback;
    }
}
