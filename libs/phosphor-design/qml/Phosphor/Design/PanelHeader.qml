// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// The top row of a page inside a panel: a back button, the name of the page, and one control.
//
// The name is the only text. A header has no line above the name and no sentence below it. Put the
// main control of the page at the right, for example the switch of the Wi-Fi page.
//
//   PanelHeader { text: "Wi-Fi"; onBack: panel.page = "main"; Switch { checked: true } }
Item {
    id: root

    property string text
    property bool canGoBack: true
    default property alias control: slot.data

    signal back

    implicitWidth: 240
    implicitHeight: Metrics.controlHeight + Metrics.space4

    IconButton {
        id: backButton

        anchors.verticalCenter: parent.verticalCenter
        visible: root.canGoBack
        iconName: "back"
        text: qsTr("Back")
        onClicked: root.back()
    }

    Text {
        anchors.left: backButton.visible ? backButton.right : parent.left
        anchors.leftMargin: backButton.visible ? Metrics.space8 : Metrics.space4
        anchors.right: slot.left
        anchors.rightMargin: Metrics.space8
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        elide: Text.ElideRight
        color: Theme.text
        font.family: Metrics.fontUi
        font.pixelSize: Metrics.textHeading
        font.weight: Metrics.weightStrong
    }

    Row {
        id: slot

        anchors.right: parent.right
        anchors.rightMargin: Metrics.space2
        anchors.verticalCenter: parent.verticalCenter
        spacing: Metrics.space4
    }
}
