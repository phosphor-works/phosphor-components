// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// A card of related settings. Put SettingRow items inside. The rows are in a column, and a line
// separates each row from the row above it.
//
// A group has no title. A group that must have a name is a section of the page, with a heading
// above the card.
Rectangle {
    default property alias rows: column.data

    implicitWidth: Metrics.pageWidth
    implicitHeight: column.height
    radius: Metrics.radiusCard
    color: Theme.card

    Column {
        id: column

        x: Metrics.padCard
        width: parent.width - 2 * Metrics.padCard
    }
}
