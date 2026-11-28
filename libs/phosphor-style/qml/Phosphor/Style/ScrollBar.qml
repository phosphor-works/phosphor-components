// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

T.ScrollBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)
    padding: 3
    visible: control.policy !== T.ScrollBar.AlwaysOff
    minimumSize: orientation === Qt.Horizontal ? height / width : width / height

    contentItem: Rectangle {
        implicitWidth: control.interactive ? 6 : 3
        implicitHeight: control.interactive ? 6 : 3
        radius: width / 2
        color: control.pressed ? Theme.text : Theme.muted
        opacity: control.policy === T.ScrollBar.AlwaysOn || (control.active && control.size < 1) ? (control.hovered || control.pressed ? 0.8 : 0.45) : 0

        Behavior on opacity {
            Fade {}
        }
    }
}
