// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// One setting. Its name is at the left and its control is at the right.
//
//   SettingGroup {
//       SettingRow { text: "Smart gaps"; Switch {} }
//       SettingRow { text: "Gap"; Slider { from: 0; to: 24 } }
//   }
//
// There is no description property, and this is intended. If the name and the control do not
// explain a setting, change the name or put a preview above the group.
Item {
    id: root

    property string text
    default property alias control: slot.data

    width: parent ? parent.width : implicitWidth
    implicitWidth: label.implicitWidth + slot.childrenRect.width + Metrics.space16
    implicitHeight: Math.max(Metrics.rowHeight, slot.childrenRect.height + 2 * Metrics.space8)

    Accessible.role: Accessible.Grouping
    Accessible.name: text

    // The line above each row, but not above the first row of its group.
    Rectangle {
        width: parent.width
        height: Metrics.lineWidth
        color: Theme.line
        visible: root.parent !== null && root.parent.children[0] !== root
    }

    Text {
        id: label

        anchors.left: parent.left
        anchors.right: slot.left
        anchors.rightMargin: Metrics.space16
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        elide: Text.ElideRight
        color: Theme.text
        font.family: Metrics.fontUi
        font.pixelSize: Metrics.textBody
        font.weight: Metrics.weightBody
    }

    Item {
        id: slot

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }
}
