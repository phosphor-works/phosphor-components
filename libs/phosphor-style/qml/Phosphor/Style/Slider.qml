// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

// The fill shows the value. After a click away from the handle, the fill moves on the flow spring.
// During a drag, the fill follows the pointer.
T.Slider {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitHandleHeight + topPadding + bottomPadding)

    background: Rectangle {
        implicitWidth: 190
        implicitHeight: 22
        radius: Metrics.radiusControl - 2
        opacity: control.enabled ? 1 : Theme.disabled
        color: Theme.track

        Rectangle {
            width: Math.max(parent.radius * 2, control.visualPosition * parent.width)
            height: parent.height
            radius: parent.radius
            color: Theme.accent
            visible: control.visualPosition > 0

            Behavior on width {
                enabled: !control.pressed

                FlowSpring {}
            }
        }

        FocusRing {
            target: control
            around: parent.radius
        }
    }

    handle: Rectangle {
        x: control.leftPadding + Math.max(4, Math.min(control.availableWidth - 8, control.visualPosition * control.availableWidth - 8))
        y: control.topPadding + (control.availableHeight - height) / 2
        implicitWidth: 4
        implicitHeight: 12
        radius: 2
        color: control.visualPosition > 0.06 ? Theme.ink : Theme.text

        Behavior on x {
            enabled: !control.pressed

            FlowSpring {}
        }
    }
}
