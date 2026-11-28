// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T
import Phosphor.Design

T.ToolButton {
    id: control

    readonly property color _ink: !enabled ? Theme.muted : checked ? Theme.accent : hovered || down ? Theme.text : Theme.muted

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)
    padding: Metrics.space6
    spacing: Metrics.space6
    scale: down ? Metrics.pressScaleSmall : 1

    font.family: Metrics.fontUi
    font.pixelSize: Metrics.textBody
    font.weight: Metrics.weightStrong

    icon.width: Metrics.iconSmall
    icon.height: Metrics.iconSmall
    icon.color: _ink

    Behavior on scale {
        SnapSpring {
            epsilon: 0.002
        }
    }

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        icon: control.icon
        text: control.text
        font: control.font
        color: control._ink
    }

    background: Rectangle {
        implicitWidth: 28
        implicitHeight: 28
        radius: Metrics.radiusControl - 2
        color: control.hovered ? Theme.hover : "transparent"

        Behavior on color {
            Tint {}
        }

        FocusRing {
            target: control
            around: parent.radius
        }
    }
}
