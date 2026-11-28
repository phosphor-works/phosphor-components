// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T

// One control of the bar. It shows icons, a short value, or the items that you put inside. `text`
// is its name for a screen reader, and the chip does not draw it.
//
// Set `active` while the panel of the chip is open. The content then has the accent color. Use the
// chip as the `source` of ShellBody, so that the panel opens from it.
//
//   BarChip {
//       text: "Quick settings"
//       icons: ["wifi", "volume", "battery"]
//       active: shell.panel === "quick"
//       onClicked: shell.toggle("quick")
//   }
T.AbstractButton {
    id: chip

    property var icons: []
    property string label
    property bool active: false
    property bool alert: false // an unread item
    default property alias items: row.data

    // The color for an item that you put inside.
    readonly property color ink: active ? Theme.accent : Theme.text

    implicitWidth: row.implicitWidth + 2 * Metrics.space10
    implicitHeight: Metrics.barHeight - Metrics.space12
    scale: down ? Metrics.pressScale : 1

    Accessible.name: text

    Behavior on scale {
        SnapSpring {
            epsilon: 0.002
        }
    }

    contentItem: Item {
        Row {
            id: row

            anchors.centerIn: parent
            spacing: Metrics.iconGap

            Repeater {
                model: chip.icons

                Icon {
                    required property string modelData

                    anchors.verticalCenter: parent.verticalCenter
                    name: modelData
                    color: chip.ink

                    Behavior on color {
                        Tint {}
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: chip.label !== ""
                text: chip.label
                color: chip.ink
                font.family: Metrics.fontUi
                font.pixelSize: Metrics.textBody
                font.weight: Metrics.weightStrong
                font.features: {
                    "tnum": 1
                }

                Behavior on color {
                    Tint {}
                }
            }
        }

        Badge {
            anchors.right: row.right
            anchors.rightMargin: -Metrics.space4
            anchors.top: row.top
            anchors.topMargin: -Metrics.space2
            shown: chip.alert
        }
    }

    background: Rectangle {
        radius: Metrics.radiusControl
        color: chip.hovered ? Theme.hover : "transparent"

        Behavior on color {
            Tint {}
        }

        FocusRing {
            target: chip
        }
    }
}
