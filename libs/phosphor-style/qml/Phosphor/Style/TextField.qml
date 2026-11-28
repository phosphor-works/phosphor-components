// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T
import Phosphor.Design

// A field has no label above it and no helper line below it. The placeholder names the content. A
// cyan edge shows focus.
T.TextField {
    id: control

    implicitWidth: implicitBackgroundWidth + leftInset + rightInset || Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding, placeholder.implicitHeight + topPadding + bottomPadding)
    leftPadding: Metrics.space12
    rightPadding: Metrics.space12
    topPadding: 0
    bottomPadding: 0

    color: Theme.text
    selectionColor: Theme.tint(Theme.accent, 0.45)
    selectedTextColor: Theme.text
    placeholderTextColor: Theme.muted
    verticalAlignment: TextInput.AlignVCenter

    font.family: Metrics.fontUi
    font.pixelSize: Metrics.textRow
    font.weight: Metrics.weightBody

    cursorDelegate: Rectangle {
        width: 2
        radius: 1
        color: Theme.focus
        visible: control.activeFocus && control.cursorVisible

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: control.activeFocus

            PauseAnimation {
                duration: 500
            }
            NumberAnimation {
                to: 0.25
                duration: 500
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                to: 1
                duration: 120
            }
        }
    }

    PlaceholderText {
        id: placeholder

        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)
        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        verticalAlignment: control.verticalAlignment
        visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
        elide: Text.ElideRight
        renderType: control.renderType
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: Metrics.fieldHeight
        radius: Metrics.radiusControl + 2
        opacity: control.enabled ? 1 : Theme.disabled
        color: Theme.field
        border.width: control.activeFocus ? 1.5 : 0
        border.color: Theme.focus
    }
}
