// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// One key of a shortcut.
Rectangle {
    property string text

    implicitWidth: Math.max(22, label.implicitWidth + 14)
    implicitHeight: 22
    radius: Metrics.radiusInner
    color: Theme.track

    Text {
        id: label

        anchors.centerIn: parent
        text: parent.text
        color: Theme.text
        font.family: Metrics.fontMono
        font.pixelSize: Metrics.textCaption
        font.weight: Metrics.weightBody
    }
}
