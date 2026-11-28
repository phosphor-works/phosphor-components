// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T

// A button that shows only an icon. `text` is its name for a screen reader. The button does not
// draw `text`.
T.Button {
    id: control

    property string iconName
    property real iconSize: Metrics.iconSmall
    property color color: hovered || down ? Theme.text : Theme.muted

    implicitWidth: 28
    implicitHeight: 28
    scale: down ? Metrics.pressScaleSmall : 1

    Accessible.name: text

    Behavior on scale {
        SnapSpring {
            epsilon: 0.002
        }
    }

    contentItem: Item {
        Icon {
            anchors.centerIn: parent
            name: control.iconName
            size: control.iconSize
            color: control.color
        }
    }

    background: Rectangle {
        radius: Metrics.radiusControl - 2
        color: control.hovered ? Theme.hover : "transparent"

        Behavior on color {
            Tint {}
        }

        FocusRing {
            target: control
            around: parent.radius
        }
    }
}
