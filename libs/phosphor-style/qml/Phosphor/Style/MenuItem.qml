// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T
import Phosphor.Design

// A checked item shows a check at its end. A submenu shows a chevron.
T.MenuItem {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding, implicitIndicatorHeight + topPadding + bottomPadding)
    padding: 0
    leftPadding: Metrics.space10
    rightPadding: 34
    spacing: Metrics.space10

    font.family: Metrics.fontUi
    font.pixelSize: Metrics.textBody
    font.weight: Metrics.weightBody

    icon.width: Metrics.iconSmall
    icon.height: Metrics.iconSmall
    icon.color: Theme.muted

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignLeft
        icon: control.icon
        text: control.text
        font: control.font
        color: control.enabled ? Theme.text : Theme.muted
    }

    indicator: Icon {
        x: control.width - width - 10
        y: (control.height - height) / 2
        name: "check"
        size: Metrics.iconSmall
        color: Theme.accent
        visible: control.checkable
        opacity: control.checked ? 1 : 0
        scale: control.checked ? 1 : 0.4

        Behavior on opacity {
            Fade {}
        }
        Behavior on scale {
            FlowSpring {
                epsilon: 0.002
            }
        }
    }

    arrow: Icon {
        x: control.width - width - 10
        y: (control.height - height) / 2
        name: "chevronRight"
        size: Metrics.iconSmall
        color: Theme.muted
        visible: control.subMenu !== null
    }

    background: Rectangle {
        implicitWidth: 188
        implicitHeight: 36
        radius: Metrics.radiusControl
        color: control.highlighted || control.down ? Theme.hover : "transparent"

        Behavior on color {
            Tint {}
        }
    }
}
