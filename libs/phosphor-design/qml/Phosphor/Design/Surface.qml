// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// A surface of the shell that does not touch the bar: a panel that is not attached, a dialog. A
// surface that touches the bar is a part of ShellBody.
Rectangle {
    default property alias content: slot.data
    property real padding: Metrics.pad

    implicitWidth: slot.childrenRect.width + 2 * padding
    implicitHeight: slot.childrenRect.height + 2 * padding
    radius: Metrics.radiusSurface
    color: Theme.shellSurface
    border.width: Metrics.lineWidth
    border.color: Theme.line

    Item {
        id: slot

        anchors.fill: parent
        anchors.margins: parent.padding
    }
}
