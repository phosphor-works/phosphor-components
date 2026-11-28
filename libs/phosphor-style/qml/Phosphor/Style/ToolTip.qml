// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

// Put an explanation here, and not on the surface.
T.ToolTip {
    id: control

    x: parent ? (parent.width - implicitWidth) / 2 : 0
    y: -implicitHeight - 6
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)
    margins: Metrics.space6
    padding: Metrics.space6
    horizontalPadding: Metrics.space10
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    font.family: Metrics.fontUi
    font.pixelSize: Metrics.textLabel
    font.weight: Metrics.weightBody

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: Motion.fadeFast
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            to: 0
            duration: Motion.fadeFast
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        wrapMode: Text.Wrap
        color: Theme.text
    }

    background: Rectangle {
        radius: Metrics.radiusControl - 2
        color: Theme.track
    }
}
