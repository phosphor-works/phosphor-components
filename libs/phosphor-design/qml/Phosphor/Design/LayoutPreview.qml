// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// A small picture of the windows on one workspace, each in its real position. The focused window
// has the cyan edge. Use it in the bar, in the overview and in a list of layouts.
//
// Each window is an object with `x`, `y`, `w` and `h` from 0 to 1. `focused` and `icon` are
// optional. Below 60 units of width, the picture shows no icons.
//
//   LayoutPreview { windows: [{ x: 0, y: 0, w: 0.6, h: 1, focused: true }, { x: 0.6, y: 0, w: 0.4, h: 1 }] }
Item {
    id: root

    property var windows: []
    // The space between two windows, and the radius of a window.
    property real gap: width < 60 ? 1 : Metrics.space2
    property real radius: width < 60 ? 2 : Metrics.radiusInner
    property color windowColor: Theme.surface

    implicitWidth: 160
    implicitHeight: 100

    Accessible.role: Accessible.Graphic

    Repeater {
        model: root.windows

        Rectangle {
            required property var modelData
            readonly property bool focused: modelData.focused === true

            x: Math.round(modelData.x * root.width) + root.gap
            y: Math.round(modelData.y * root.height) + root.gap
            width: Math.round(modelData.w * root.width) - 2 * root.gap
            height: Math.round(modelData.h * root.height) - 2 * root.gap
            radius: root.radius
            color: root.width < 60 && focused ? Theme.focus : root.windowColor
            border.width: root.width < 60 ? 0 : focused ? Metrics.focusWidth : Metrics.lineWidth
            border.color: focused ? Theme.focus : Theme.line

            Behavior on x {
                FlowSpring {}
            }
            Behavior on y {
                FlowSpring {}
            }
            Behavior on width {
                FlowSpring {}
            }
            Behavior on height {
                FlowSpring {}
            }

            Icon {
                anchors.centerIn: parent
                // A window that is smaller than the icon shows no icon.
                visible: root.width >= 60 && parent.modelData.icon !== undefined && parent.width >= size + Metrics.space6 && parent.height >= size + Metrics.space6
                name: parent.modelData.icon ?? ""
                size: Metrics.iconSmall
                color: parent.focused ? Theme.text : Theme.muted
            }
        }
    }
}
