// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

// A card: one group of related rows on a window.
T.Frame {
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)
    padding: Metrics.space2
    horizontalPadding: Metrics.space16

    background: Rectangle {
        radius: Metrics.radiusCard
        color: Theme.card
    }
}
