// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T

// Selects one of the four brand colors as the accent. The chosen swatch changes from a circle to a
// rounded square.
Row {
    id: root

    property string value: "blue"
    readonly property var _stops: [["blue", Theme.blue], ["cyan", Theme.cyan], ["purple", Theme.purple], ["rose", Theme.rose]]

    signal picked(string value)

    spacing: Metrics.space8

    Repeater {
        model: root._stops

        delegate: T.AbstractButton {
            id: swatch

            required property var modelData
            readonly property bool on: modelData[0] === root.value

            width: 26
            height: 26
            scale: down ? Metrics.pressScaleSmall : 1

            Accessible.name: modelData[0]

            onClicked: {
                root.value = modelData[0];
                root.picked(modelData[0]);
            }

            Behavior on scale {
                SnapSpring {
                    epsilon: 0.002
                }
            }

            background: Rectangle {
                radius: swatch.on ? 8 : 13
                color: swatch.modelData[1]

                Behavior on radius {
                    SnapSpring {}
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: parent.radius + 4
                    color: "transparent"
                    border.width: 2
                    border.color: swatch.modelData[1]
                    visible: swatch.on || swatch.visualFocus
                }
            }
        }
    }
}
