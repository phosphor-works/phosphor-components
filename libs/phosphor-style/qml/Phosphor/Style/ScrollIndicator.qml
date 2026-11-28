// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

T.ScrollIndicator {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)
    padding: Metrics.space2

    contentItem: Rectangle {
        implicitWidth: 3
        implicitHeight: 3
        radius: 1.5
        color: Theme.muted
        opacity: control.active && control.size < 1 ? 0.5 : 0

        Behavior on opacity {
            Fade {}
        }
    }
}
