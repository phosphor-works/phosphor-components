// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// A window of a Phosphor app: a title bar and the content below it.
//
// The title bar shows the icon of the app, one title and the three window buttons. The focused
// window has the cyan edge and a bright title. A window that is not focused has a dim title. Put
// the controls of the app in `tools`. They appear before the window buttons.
//
//   WindowFrame { icon: "terminal"; title: "Afterglow"; focused: true; Terminal { anchors.fill: parent } }
Rectangle {
    id: root

    property string icon
    property string title
    property bool focused: false
    property bool buttons: true
    property alias tools: toolSlot.data
    default property alias content: body.data

    readonly property real titleHeight: Metrics.controlHeight + Metrics.space12

    signal minimized
    signal maximized
    signal closed

    implicitWidth: 480
    implicitHeight: 320
    radius: Metrics.radiusSurface
    color: Theme.surface
    border.width: focused ? Metrics.focusWidth : Metrics.lineWidth
    border.color: focused ? Theme.focus : Theme.line

    Behavior on border.color {
        Tint {}
    }

    Item {
        id: bar

        x: root.border.width
        y: root.border.width
        width: root.width - 2 * root.border.width
        height: root.titleHeight

        Icon {
            id: glyph

            x: Metrics.padCard - root.border.width
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            name: root.icon
            size: Metrics.iconSmall
            color: root.focused ? Theme.text : Theme.muted
        }

        Text {
            anchors.left: glyph.visible ? glyph.right : parent.left
            anchors.leftMargin: glyph.visible ? Metrics.iconGap : Metrics.padCard
            anchors.right: trailing.left
            anchors.rightMargin: Metrics.space8
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            elide: Text.ElideRight
            color: root.focused ? Theme.text : Theme.muted
            font.family: Metrics.fontUi
            font.pixelSize: Metrics.textLabel
            font.weight: Metrics.weightStrong

            Behavior on color {
                Tint {}
            }
        }

        Row {
            id: trailing

            anchors.right: parent.right
            anchors.rightMargin: Metrics.space8
            anchors.verticalCenter: parent.verticalCenter
            spacing: Metrics.space2

            Row {
                id: toolSlot

                anchors.verticalCenter: parent.verticalCenter
                spacing: Metrics.space2
            }

            IconButton {
                visible: root.buttons
                iconName: "minimize"
                text: qsTr("Minimize")
                onClicked: root.minimized()
            }
            IconButton {
                visible: root.buttons
                iconName: "maximize"
                text: qsTr("Maximize")
                onClicked: root.maximized()
            }
            IconButton {
                visible: root.buttons
                iconName: "close"
                text: qsTr("Close")
                onClicked: root.closed()
            }
        }
    }

    Item {
        id: body

        x: root.border.width
        y: bar.y + bar.height
        width: root.width - 2 * root.border.width
        height: root.height - y - root.border.width
        clip: true
    }
}
