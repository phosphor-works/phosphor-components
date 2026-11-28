// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T
import Phosphor.Design

// For a choice with too many options for a segmented control. The list opens from the button and
// extends down.
T.ComboBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding, implicitIndicatorHeight + topPadding + bottomPadding)
    leftPadding: Metrics.space12
    rightPadding: Metrics.space32

    font.family: Metrics.fontUi
    font.pixelSize: Metrics.textBody
    font.weight: Metrics.weightStrong

    delegate: ItemDelegate {
        required property var model
        required property int index

        width: ListView.view.width
        text: model[control.textRole]
        highlighted: control.highlightedIndex === index
    }

    indicator: Icon {
        x: control.width - width - 10
        y: (control.height - height) / 2
        name: "chevronDown"
        size: Metrics.iconSmall
        color: Theme.muted
        rotation: control.popup.visible ? 180 : 0

        Behavior on rotation {
            FlowSpring {}
        }
    }

    contentItem: Text {
        text: control.displayText
        font: control.font
        color: Theme.text
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitWidth: 150
        implicitHeight: Metrics.controlHeight
        radius: Metrics.radiusControl - 1
        opacity: control.enabled ? 1 : Theme.disabled
        color: control.hovered || control.popup.visible ? Theme.track : Theme.field

        Behavior on color {
            Tint {}
        }

        FocusRing {
            target: control
            around: parent.radius
        }
    }

    popup: T.Popup {
        y: control.height + 6
        width: control.width
        height: Math.min(contentItem.implicitHeight + 8, control.Window.height - topMargin - bottomMargin)
        topMargin: 8
        bottomMargin: 8
        padding: Metrics.space4
        transformOrigin: Item.Top

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
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0

            T.ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            radius: Metrics.radiusCard
            color: Theme.surface
            border.width: Metrics.lineWidth
            border.color: Theme.line
        }
    }
}
