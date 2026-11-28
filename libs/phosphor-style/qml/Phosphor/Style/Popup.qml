// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

T.Popup {
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)
    padding: Metrics.pad

    background: Rectangle {
        radius: Metrics.radiusSurface
        color: Theme.surface
        border.width: Metrics.lineWidth
        border.color: Theme.line
    }

    T.Overlay.modal: Rectangle {
        color: Theme.shade
    }
}
