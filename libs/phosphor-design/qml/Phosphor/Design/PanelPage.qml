// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// One page of a panel that has more than one page, for example the main page of the quick settings
// and its Wi-Fi page. The pages are in the same place. Only the page with `active` is visible.
//
// A page that is not active waits at the side: a detail page (`deeper`) at the right, and the page
// above it at the left. Thus a detail page comes in from the right, and "back" goes to the left.
//
// The owner sets its `implicitHeight` to the height of the active page. ShellBody then changes the
// size of the same drawer. It does not open a second panel.
//
//   Item {
//       implicitHeight: page === "main" ? main.implicitHeight : wifi.implicitHeight
//       PanelPage { id: main; active: page === "main"; deeper: false }
//       PanelPage { id: wifi; active: page === "wifi" }
//   }
Column {
    id: root

    property bool active: false
    property bool deeper: true

    x: active ? 0 : deeper ? Metrics.space48 : -Metrics.space48
    opacity: active ? 1 : 0
    visible: opacity > 0
    enabled: active

    Behavior on x {
        FlowSpring {}
    }
    Behavior on opacity {
        Fade {}
    }
}
