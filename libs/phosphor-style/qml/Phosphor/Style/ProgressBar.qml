// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

T.ProgressBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)

    contentItem: Item {
        implicitHeight: 6

        Rectangle {
            width: Math.max(height, control.visualPosition * parent.width)
            height: parent.height
            radius: height / 2
            color: Theme.accent
            visible: !control.indeterminate && control.visualPosition > 0

            Behavior on width {
                FlowSpring {}
            }
        }

        // For an unknown length: a short accent band that moves across the track.
        Rectangle {
            width: parent.width * 0.3
            height: parent.height
            radius: height / 2
            color: Theme.accent
            visible: control.indeterminate

            SequentialAnimation on x {
                loops: Animation.Infinite
                running: control.indeterminate && control.visible

                NumberAnimation {
                    from: 0
                    to: control.width * 0.7
                    duration: 900
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    from: control.width * 0.7
                    to: 0
                    duration: 900
                    easing.type: Easing.InOutCubic
                }
            }
        }
    }

    background: Rectangle {
        implicitWidth: 160
        implicitHeight: 6
        radius: height / 2
        color: Theme.track
    }
}
