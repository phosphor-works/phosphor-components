// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

T.Menu {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)
    margins: 0
    padding: Metrics.space6
    overlap: 4
    transformOrigin: Item.Top

    delegate: MenuItem {}

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: Motion.fadeFast
        }
        SpringAnimation {
            property: "scale"
            from: 0.9
            to: 1
            spring: Motion.flowSpring
            damping: Motion.flowDamping
            epsilon: 0.002
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            to: 0
            duration: Motion.fadeFast
        }
    }

    contentItem: ListView {
        implicitHeight: contentHeight
        model: control.contentModel
        interactive: Window.window ? contentHeight + control.topPadding + control.bottomPadding > control.height : false
        clip: true
        currentIndex: control.currentIndex

        T.ScrollIndicator.vertical: ScrollIndicator {}
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 36
        radius: Metrics.radiusCard
        color: Theme.surface
        border.width: Metrics.lineWidth
        border.color: Theme.line
    }
}
