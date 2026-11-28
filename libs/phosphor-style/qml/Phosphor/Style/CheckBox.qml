// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

T.CheckBox {
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
        radius: Metrics.radiusInner + 1
        opacity: control.enabled ? 1 : Theme.disabled
        color: control.checkState !== Qt.Unchecked ? Theme.accent : Theme.track
        scale: control.down ? Metrics.pressScaleSmall : 1

        Behavior on color {
            Tint {}
        }
        Behavior on scale {
            SnapSpring {
                epsilon: 0.002
            }
        }

        Icon {
            anchors.centerIn: parent
            name: control.checkState === Qt.PartiallyChecked ? "minimize" : "check"
            size: Metrics.iconSmall
            color: Theme.ink
            opacity: control.checkState !== Qt.Unchecked ? 1 : 0
            scale: control.checkState !== Qt.Unchecked ? 1 : 0.4

            Behavior on opacity {
                Fade {}
            }
            Behavior on scale {
                FlowSpring {
                    epsilon: 0.002
                }
            }
        }

        FocusRing {
            target: control
            around: parent.radius
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
