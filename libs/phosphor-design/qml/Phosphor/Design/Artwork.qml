// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Effects

// A picture with round corners: the cover of an album, the preview of a file. Until the picture is
// ready, and when there is no picture, the item shows `icon` on a plate in `tone`.
//
//   Artwork { source: player.artUrl; size: 52 }
Item {
    id: root

    property url source
    property string icon: "music"
    property color tone: Theme.accent
    property real size: 52
    property real radius: Math.min(Metrics.radiusControl + 2, size / 2)
    // The picture loads in a different thread, so a large file does not stop the interface. Set
    // this to false when the picture must be there in the first frame.
    property bool asynchronous: true

    readonly property bool ready: picture.status === Image.Ready
    // The software renderer has no effects. It shows the picture with square corners.
    readonly property bool _effects: GraphicsInfo.api !== GraphicsInfo.Software

    implicitWidth: size
    implicitHeight: size

    Accessible.role: Accessible.Graphic

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.tint(root.tone, 0.16)
        visible: !root.ready

        Icon {
            anchors.centerIn: parent
            name: root.icon
            size: Math.round(Math.min(root.width, root.height) * 0.5)
            color: root.tone
        }
    }

    Image {
        id: picture

        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: root.asynchronous
        // The effect below draws the picture with the round corners.
        visible: root.ready && !root._effects
        sourceSize.width: Math.ceil(root.width * 2)
        sourceSize.height: Math.ceil(root.height * 2)
    }

    Item {
        id: corners

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: root.radius
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: picture
        maskEnabled: true
        maskSource: corners
        visible: root.ready && root._effects
        opacity: root.ready ? 1 : 0

        Behavior on opacity {
            Fade {}
        }
    }
}
