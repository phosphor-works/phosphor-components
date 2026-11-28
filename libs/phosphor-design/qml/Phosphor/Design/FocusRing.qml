// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// The keyboard focus ring. Cyan always shows focus: this ring, the focused window and the cursor of
// the terminal. Put the ring in the background of a control.
Rectangle {
    property Item target: parent
    property real around: Metrics.radiusControl

    anchors.fill: parent
    anchors.margins: -Metrics.focusOffset
    radius: around + Metrics.focusOffset
    color: "transparent"
    border.width: Metrics.focusWidth
    border.color: Theme.focus
    visible: target !== null && target.visualFocus === true
}
