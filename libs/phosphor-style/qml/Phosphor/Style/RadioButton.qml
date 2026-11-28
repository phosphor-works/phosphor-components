// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

T.RadioButton {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding, implicitIndicatorHeight + topPadding + bottomPadding)
    padding: 0
    spacing: Metrics.space10

    font.family: Metrics.fontUi
    font.pixelSize: Metrics.textBody
    font.weight: Metrics.weightBody

    indicator: Rectangle {
        implicitWidth: 22
        implicitHeight: 22
        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: 11
        opacity: control.enabled ? 1 : Theme.disabled
        color: control.checked ? Theme.accent : Theme.track

        Behavior on color {
            Tint {}
        }

        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: Theme.ink
            scale: control.checked ? (control.down ? 0.7 : 1) : 0

            Behavior on scale {
                FlowSpring {
                    epsilon: 0.002
                }
            }
        }

        FocusRing {
            target: control
            around: 11
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
