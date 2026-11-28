// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T

// The workspaces in the bar. Each workspace is a dot. The current workspace has the accent pill
// behind it, and the pill stretches to the workspace that the user selects. A workspace that
// contains a window has a bright dot. An empty workspace has a dim dot.
//
// The strip shows no numbers. The position of a dot is its number.
Item {
    id: root

    property int count: 4
    property int current: 0
    property var occupied: [] // the indexes of the workspaces that contain a window

    signal picked(int index)

    implicitWidth: row.width
    implicitHeight: Metrics.barHeight - Metrics.space12

    Accessible.role: Accessible.PageTabList
    Accessible.name: qsTr("Workspaces")

    StretchIndicator {
        anchors.fill: parent
        inset: (root.height - 20) / 2
        radius: 10
        target: dots.count > root.current ? dots.itemAt(root.current) : null
    }

    Row {
        id: row

        height: parent.height

        Repeater {
            id: dots

            model: root.count

            T.AbstractButton {
                id: dot

                required property int index
                readonly property bool isCurrent: index === root.current

                width: Metrics.targetMin
                height: row.height

                Accessible.name: qsTr("Workspace %1").arg(index + 1)
                Accessible.role: Accessible.PageTab

                onClicked: root.picked(index)

                contentItem: Item {
                    Rectangle {
                        anchors.centerIn: parent
                        width: dot.isCurrent ? 12 : 6
                        height: 6
                        radius: 3
                        color: dot.isCurrent ? Theme.ink : Theme.text
                        opacity: dot.isCurrent || root.occupied.includes(dot.index) ? 1 : 0.3
                        scale: dot.down ? Metrics.pressScaleSmall : dot.hovered && !dot.isCurrent ? 1.3 : 1

                        Behavior on width {
                            FlowSpring {}
                        }
                        Behavior on scale {
                            SnapSpring {
                                epsilon: 0.002
                            }
                        }
                        Behavior on color {
                            Tint {}
                        }
                        Behavior on opacity {
                            Fade {}
                        }
                    }
                }

                background: Item {
                    FocusRing {
                        target: dot
                        around: Metrics.radiusControl
                    }
                }
            }
        }
    }
}
