// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// An item that the user did not see: a dot, or a number when `count` is above 0. Rose is the color
// of an unread item. Set `shown` to false and the badge becomes small and goes away.
Rectangle {
    id: root

    property int count: 0
    property bool shown: true

    implicitWidth: count > 0 ? Math.max(16, tally.implicitWidth + Metrics.space8) : 8
    implicitHeight: count > 0 ? 16 : 8
    radius: height / 2
    color: Theme.danger
    scale: shown ? 1 : 0
    opacity: shown ? 1 : 0

    Behavior on scale {
        FlowSpring {
            epsilon: 0.002
        }
    }
    Behavior on opacity {
        Fade {}
    }

    Text {
        id: tally

        anchors.centerIn: parent
        visible: root.count > 0
        text: root.count > 99 ? "99+" : root.count
        color: Theme.ink
        font.family: Metrics.fontMono
        font.pixelSize: Metrics.textCaption
        font.weight: Metrics.weightStrong
    }
}
