// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T
import Phosphor.Design

// A row in a list. The current row has a tint and not a fill. A fill is for small controls.
T.ItemDelegate {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding, implicitIndicatorHeight + topPadding + bottomPadding)
    padding: 0
    horizontalPadding: Metrics.space10
    spacing: 11

    font.family: Metrics.fontUi
    font.pixelSize: Metrics.textBody
    font.weight: Metrics.weightBody

    icon.width: Metrics.iconSmall
    icon.height: Metrics.iconSmall
    icon.color: highlighted ? Theme.accent : Theme.muted

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: control.display === IconLabel.IconOnly || control.display === IconLabel.TextUnderIcon ? Qt.AlignCenter : Qt.AlignLeft
        icon: control.icon
        text: control.text
        font: control.font
        color: control.highlighted || control.hovered ? Theme.text : Theme.muted
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 36
        radius: Metrics.radiusControl
        color: control.highlighted ? Theme.selected : control.hovered ? Theme.hover : "transparent"

        Behavior on color {
            Tint {}
        }

        FocusRing {
            target: control
            around: parent.radius
        }
    }
}
