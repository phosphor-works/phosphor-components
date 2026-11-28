// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Shapes

// The recent history of one value. `values` are from 0 to 1, with the oldest value first.
Item {
    id: root

    property var values: []
    property color color: Theme.accent

    readonly property var _points: {
        const n = values.length;
        if (n < 2)
            return [Qt.point(0, height - 1), Qt.point(width, height - 1)];
        return values.map((v, i) => Qt.point(i / (n - 1) * width, 1 + (1 - Math.min(1, Math.max(0, v))) * (height - 2)));
    }

    implicitWidth: 120
    implicitHeight: 28

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.6
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathPolyline {
                path: root._points
            }
        }
    }
}
