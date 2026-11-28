// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

T.MenuSeparator {
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)
    padding: 5
    horizontalPadding: Metrics.space10

    contentItem: Rectangle {
        implicitWidth: 188
        implicitHeight: 1
        color: Theme.line
    }
}
