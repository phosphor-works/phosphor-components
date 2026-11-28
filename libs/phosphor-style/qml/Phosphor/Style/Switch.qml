// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

// When the switch is on, the track has the accent color and the knob has the ink color. The knob is
// wider while the user holds it, and it moves on the snap spring.
T.Switch {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding, implicitIndicatorHeight + topPadding + bottomPadding)
    padding: 0
    spacing: Metrics.space10

    font.family: Metrics.fontUi
    font.pixelSize: Metrics.textBody
    font.weight: Metrics.weightBody

    indicator: Rectangle {
        implicitWidth: 44
        implicitHeight: 26
        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: 13
        opacity: control.enabled ? 1 : Theme.disabled
        color: control.checked ? Theme.accent : Theme.track

        Behavior on color {
            Tint {}
        }

        Rectangle {
            x: 3 + (control.checked ? 18 - (control.down ? 7 : 0) : 0)
            y: 3
            width: control.down ? 27 : 20
            height: 20
            radius: 10
            color: control.checked ? Theme.ink : Theme.muted

            Behavior on x {
                SnapSpring {}
            }
            Behavior on width {
                SnapSpring {}
            }
            Behavior on color {
                Tint {}
            }
        }

        FocusRing {
            target: control
            around: 13
        }
    }

    contentItem: Text {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
        text: control.text
        font: control.font
        color: Theme.text
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }
}
