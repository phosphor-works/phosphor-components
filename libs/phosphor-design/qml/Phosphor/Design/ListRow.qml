// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T

// One row of a list from which the user selects an item: networks, devices, outputs, apps.
//
// The row shows a state with a drawing and not with text. `selected` gives the row the accent color
// and a check. `busy` shows a spinner. `secure` shows a lock. `value` shows a real value, for
// example a battery level. An item that you put in the row appears below it. Put a password field
// or a pairing code there.
Column {
    id: root

    property string icon
    property real iconOpacity: 1 // signal strength, say
    property string text
    property string value
    property bool secure: false
    property bool selected: false
    property bool busy: false
    property bool highlighted: false // the keyboard's current row in a launcher
    default property alias extra: extraSlot.data

    signal clicked

    readonly property color _ink: selected ? Theme.accent : Theme.text

    width: parent ? parent.width : implicitWidth

    T.AbstractButton {
        id: row

        width: root.width
        implicitHeight: Metrics.listRowHeight

        Accessible.name: root.text

        onClicked: root.clicked()

        contentItem: Item {
            Icon {
                id: glyph

                x: Metrics.padRow
                anchors.verticalCenter: parent.verticalCenter
                name: root.icon
                color: root._ink
                opacity: root.iconOpacity
                visible: root.icon !== ""
            }

            Text {
                anchors.left: glyph.visible ? glyph.right : parent.left
                anchors.leftMargin: glyph.visible ? 12 : 10
                anchors.right: trailing.left
                anchors.rightMargin: Metrics.space8
                anchors.verticalCenter: parent.verticalCenter
                text: root.text
                elide: Text.ElideRight
                color: root._ink
                font.family: Metrics.fontUi
                font.pixelSize: Metrics.textRow
                font.weight: Metrics.weightBody

                Behavior on color {
                    Tint {}
                }
            }

            Row {
                id: trailing

                anchors.right: parent.right
                anchors.rightMargin: Metrics.space10
                anchors.verticalCenter: parent.verticalCenter
                spacing: Metrics.space10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.value !== ""
                    text: root.value
                    color: Theme.muted
                    font.family: Metrics.fontMono
                    font.pixelSize: Metrics.textLabel
                }

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.secure
                    name: "lock"
                    size: Metrics.iconSmall
                    color: Theme.muted
                }

                Spinner {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.busy
                }

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.busy
                    name: "check"
                    color: Theme.accent
                    opacity: root.selected ? 1 : 0
                    scale: root.selected ? 1 : 0.4

                    Behavior on opacity {
                        Fade {}
                    }
                    Behavior on scale {
                        FlowSpring {
                            epsilon: 0.002
                        }
                    }
                }
            }
        }

        background: Rectangle {
            radius: Metrics.radiusControl + 2
            color: root.highlighted ? Theme.selected : row.hovered ? Theme.hover : "transparent"

            Behavior on color {
                Tint {}
            }

            FocusRing {
                target: row
                around: parent.radius
            }
        }
    }

    Item {
        id: extraSlot

        width: root.width
        height: childrenRect.height
        visible: children.length > 0
    }
}
