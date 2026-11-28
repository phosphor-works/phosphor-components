// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T
import Phosphor.Design

// `highlighted` gives the accent button: the one action that a surface requests. `flat` gives the
// button with no ground, for the action that cancels. A button becomes smaller while the pointer
// presses it, and the snap spring returns it.
T.Button {
    id: control

    readonly property color _ink: !enabled ? Theme.muted : highlighted ? Theme.ink : flat && !hovered ? Theme.muted : Theme.text

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)
    padding: 0
    horizontalPadding: Metrics.padControl
    spacing: Metrics.space8
    scale: down ? Metrics.pressScale : 1

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
        implicitWidth: 30
        implicitHeight: Metrics.controlHeight
        radius: Metrics.radiusControl - 1
        opacity: control.enabled ? 1 : Theme.disabled
        color: control.highlighted ? Theme.accent : control.flat ? (control.hovered ? Theme.hover : "transparent") : control.hovered ? Theme.track : Theme.field

        Behavior on color {
            Tint {}
        }

        FocusRing {
            target: control
            around: parent.radius
        }
    }
}
