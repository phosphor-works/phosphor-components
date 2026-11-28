// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T
import Phosphor.Design

T.TabButton {
    id: control

    readonly property color _ink: checked || hovered ? Theme.text : Theme.muted

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)
    padding: 0
    horizontalPadding: Metrics.padControl
    spacing: Metrics.space6

    font.family: Metrics.fontUi
    font.pixelSize: Metrics.textLabel
    font.weight: Metrics.weightBody

    icon.width: Metrics.iconSmall
    icon.height: Metrics.iconSmall
    icon.color: _ink

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        icon: control.icon
        text: control.text
        font: control.font
        color: control._ink

        Behavior on color {
            Tint {}
        }
    }

    background: Item {
        implicitHeight: 28

        FocusRing {
            target: control
        }
    }
}
