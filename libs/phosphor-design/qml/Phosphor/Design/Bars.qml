// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// Sound that plays: four bars that move. When `running` is false, the bars are short and do not
// move. Thus the bars show "playing" and "paused" without a word.
//
// Set `levels` to four values from 0 to 1 to show real audio. Without `levels`, the bars move in a
// fixed pattern.
Item {
    id: root

    property bool running: true
    property var levels: []
    property color color: Theme.accent

    implicitWidth: 4 * 3 + 3 * 2
    implicitHeight: 14

    Row {
        anchors.fill: parent
        spacing: 2

        Repeater {
            model: 4

            Item {
                id: slot

                required property int index
                // One pattern for each bar, so that the bars do not move together.
                readonly property var pattern: [[0.9, 0.35, 0.7, 0.5], [0.4, 1, 0.55, 0.8], [0.75, 0.45, 1, 0.3], [0.5, 0.8, 0.35, 0.95]][index]
                property int step: 0
                readonly property real level: !root.running ? 0.2 : root.levels.length === 4 ? root.levels[index] : pattern[step]

                width: 3
                height: root.height

                Timer {
                    interval: 240 * Motion.slow
                    repeat: true
                    running: root.running && root.levels.length !== 4 && root.visible && !Motion.reduced
                    onTriggered: slot.step = (slot.step + 1) % 4
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(3, slot.level * parent.height)
                    radius: 1.5
                    color: root.color

                    Behavior on height {
                        TrailSpring {}
                    }
                    Behavior on color {
                        Tint {}
                    }
                }
            }
        }
    }
}
