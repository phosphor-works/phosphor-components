// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// A level, from 0 to 1. The fill shows the state. If there is a number, put it next to the meter.
Item {
    id: root

    property real value: 0
    property color color: Theme.accent

    implicitWidth: 160
    implicitHeight: 6

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.track

        Rectangle {
            width: Math.max(parent.height, Math.min(1, Math.max(0, root.value)) * parent.width)
            height: parent.height
            radius: parent.radius
            color: root.color
            visible: root.value > 0

            Behavior on width {
                FlowSpring {}
            }
            Behavior on color {
                Tint {}
            }
        }
    }
}
