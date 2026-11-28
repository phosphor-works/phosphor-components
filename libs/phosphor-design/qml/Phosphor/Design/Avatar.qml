// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// A person or an app as a small plate. It shows the icon in `icon`. Without an icon, it shows the
// first letter of `name`. `tone` is the color of the plate and of its content.
Rectangle {
    id: root

    property string name
    property string icon
    property color tone: Theme.accent
    property real size: 40

    implicitWidth: size
    implicitHeight: size
    radius: Math.min(Metrics.radiusControl + 2, size / 2)
    color: Theme.tint(tone, 0.16)

    Accessible.role: Accessible.Graphic
    Accessible.name: name

    Icon {
        anchors.centerIn: parent
        visible: root.icon !== ""
        name: root.icon
        size: Math.round(root.size * 0.5)
        color: root.tone
    }

    Text {
        anchors.centerIn: parent
        visible: root.icon === ""
        text: root.name.charAt(0).toUpperCase()
        color: root.tone
        font.family: Metrics.fontUi
        font.pixelSize: Math.round(root.size * 0.42)
        font.weight: Metrics.weightStrong
    }
}
