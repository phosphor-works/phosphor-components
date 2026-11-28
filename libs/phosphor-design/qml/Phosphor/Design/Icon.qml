// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Shapes

// One icon from Icons. It has a stroke of 1.7 units on the 24 unit grid, and `size` sets its scale.
Item {
    id: root

    property string name
    property color color: Theme.text
    property real size: Metrics.iconSize

    readonly property var _glyph: Icons.set[name] ?? null
    readonly property real _scale: _glyph ? size / _glyph.box[2] : 1

    implicitWidth: size
    implicitHeight: size

    Shape {
        visible: root._glyph !== null
        x: root._glyph ? -root._glyph.box[0] * root._scale : 0
        y: root._glyph ? -root._glyph.box[1] * root._scale : 0
        scale: root._scale
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root._glyph && !root._glyph.fill ? root.color : "transparent"
            fillColor: root._glyph && root._glyph.fill ? root.color : "transparent"
            strokeWidth: Metrics.iconStroke
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathSvg {
                path: root._glyph ? root._glyph.d : ""
            }
        }
    }
}
