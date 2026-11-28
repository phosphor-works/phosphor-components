// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// The selection indicator of each list, tab bar and segmented control.
//
// It follows `target`. The edge in the direction of the move uses the flow spring, and the other
// edge uses the trail spring. Thus the indicator becomes longer in the direction of its new
// position, and then becomes shorter.
//
// Make it fill the container, and put it below the items.
Item {
    id: root

    property Item target
    property bool vertical: false
    property color color: Theme.accent
    property real radius: Metrics.radiusInner + 1
    property real inset: 0 // gap between the pill and the container, across the axis

    // The two edges on the axis, in the coordinates of this item.
    property real _near: 0
    property real _far: 0
    property bool _forward: true
    property bool _placed: false

    function _follow() {
        if (!target || !target.visible) {
            pill.opacity = 0;
            return;
        }
        const origin = root.mapFromItem(target, 0, 0);
        const near = vertical ? origin.y : origin.x;
        const far = near + (vertical ? target.height : target.width);
        if (far - near <= 0)
            return;
        _forward = near > _near;
        _near = near;
        _far = far;
        pill.opacity = 1;
        // The first position has no animation, because there is no earlier position.
        if (!_placed)
            Qt.callLater(() => root._placed = true);
    }

    // Moves to the target immediately. Use it when the container moved the target, for example when
    // a list above it opened. That is not a change of selection and must not look like one.
    function reposition() {
        _placed = false;
        _follow();
    }

    onTargetChanged: Qt.callLater(_follow)
    onWidthChanged: Qt.callLater(_follow)
    onHeightChanged: Qt.callLater(_follow)
    Component.onCompleted: Qt.callLater(_follow)

    Connections {
        target: root.target
        ignoreUnknownSignals: true

        function onXChanged() {
            Qt.callLater(root._follow);
        }
        function onYChanged() {
            Qt.callLater(root._follow);
        }
        function onWidthChanged() {
            Qt.callLater(root._follow);
        }
        function onHeightChanged() {
            Qt.callLater(root._follow);
        }
        function onVisibleChanged() {
            Qt.callLater(root._follow);
        }
    }

    Behavior on _near {
        enabled: root._placed

        SpringAnimation {
            spring: root._forward ? Motion.trailSpring : Motion.flowSpring
            damping: root._forward ? Motion.trailDamping : Motion.flowDamping
            epsilon: 0.05
        }
    }

    Behavior on _far {
        enabled: root._placed

        SpringAnimation {
            spring: root._forward ? Motion.flowSpring : Motion.trailSpring
            damping: root._forward ? Motion.flowDamping : Motion.trailDamping
            epsilon: 0.05
        }
    }

    Rectangle {
        id: pill

        readonly property real start: Math.min(root._near, root._far)
        readonly property real length: Math.max(6, Math.abs(root._far - root._near))

        x: root.vertical ? root.inset : start
        y: root.vertical ? start : root.inset
        width: root.vertical ? root.width - 2 * root.inset : length
        height: root.vertical ? length : root.height - 2 * root.inset
        radius: root.radius
        color: root.color
        opacity: 0

        Behavior on color {
            Tint {}
        }
    }
}
