// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T

// A quick setting. When it is off, it is a rounded rectangle. When it is on, it has an accent fill
// and is a pill. Thus shape and color show the state.
//
// The icon names the item and the text gives its value. A Wi-Fi tile shows "Home network", not
// "Wi-Fi: connected to Home network".
Item {
    id: root

    property string icon
    property string text
    property bool checked: false
    property bool hasMore: false // a detail page opens from the trailing button
    property string moreLabel

    signal toggled
    signal moreClicked

    readonly property color _ink: checked ? Theme.ink : Theme.text
    readonly property alias plate: plate

    implicitWidth: 180
    implicitHeight: Metrics.tileHeight

    Rectangle {
        id: plate

        anchors.fill: parent
        radius: root.checked ? height / 2 : Metrics.radiusCard
        color: root.checked ? Theme.accent : Theme.track

        Behavior on radius {
            FlowSpring {}
        }
        Behavior on color {
            Tint {}
        }
    }

    T.AbstractButton {
        id: main

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: more.visible ? more.left : parent.right
        scale: down ? Metrics.pressScale : 1

        Accessible.name: root.text
        Accessible.role: Accessible.CheckBox
        Accessible.checked: root.checked

        onClicked: root.toggled()

        Behavior on scale {
            SnapSpring {
                epsilon: 0.002
            }
        }

        contentItem: Item {
            Icon {
                id: glyph

                x: Metrics.padControl
                anchors.verticalCenter: parent.verticalCenter
                name: root.icon
                color: root._ink
            }

            Text {
                anchors.left: glyph.right
                anchors.leftMargin: Metrics.space10
                anchors.right: parent.right
                anchors.rightMargin: Metrics.space8
                anchors.verticalCenter: parent.verticalCenter
                text: root.text
                elide: Text.ElideRight
                color: root._ink
                font.family: Metrics.fontUi
                font.pixelSize: Metrics.textBody
                font.weight: Metrics.weightStrong
            }
        }

        background: FocusRing {
            target: main
            around: plate.radius
        }
    }

    T.AbstractButton {
        id: more

        anchors.right: parent.right
        anchors.rightMargin: Metrics.space10
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        visible: root.hasMore
        scale: down ? Metrics.pressScaleSmall : 1

        Accessible.name: root.moreLabel

        onClicked: root.moreClicked()

        Behavior on scale {
            SnapSpring {
                epsilon: 0.002
            }
        }

        contentItem: Item {
            Icon {
                anchors.centerIn: parent
                name: "chevronRight"
                size: Metrics.iconSmall
                color: root._ink
            }
        }

        background: Rectangle {
            radius: 13
            color: Theme.tint(root._ink, 0.14)

            FocusRing {
                target: more
                around: 13
            }
        }
    }
}
