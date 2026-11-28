// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T

// The slider of the shell. It has a thick track, and its fill is the handle. The icon is inside the
// fill. `label` gives the name of the item when a row of sliders needs names.
T.Slider {
    id: control

    property string iconName
    property string label

    // The fill is always wider than the icon, so that the icon is always on the accent.
    readonly property real _least: 46
    readonly property real _fill: _least + visualPosition * (width - _least)

    implicitWidth: 220
    implicitHeight: 38

    Accessible.name: label

    background: Rectangle {
        radius: Metrics.radiusCard
        color: Theme.track

        Rectangle {
            width: control._fill
            height: parent.height
            radius: parent.radius
            color: Theme.accent

            Behavior on width {
                enabled: !control.pressed

                FlowSpring {}
            }
        }

        Icon {
            id: glyph

            x: Metrics.space12
            anchors.verticalCenter: parent.verticalCenter
            name: control.iconName
            color: Theme.ink
        }

        Text {
            anchors.left: glyph.right
            anchors.leftMargin: Metrics.space10
            anchors.verticalCenter: parent.verticalCenter
            visible: control.label !== ""
            text: control.label
            color: Theme.ink
            font.family: Metrics.fontUi
            font.pixelSize: Metrics.textBody
            font.weight: Metrics.weightStrong
        }

        FocusRing {
            target: control
            around: parent.radius
        }
    }

    handle: Item {
        x: control._fill
    }
}
