// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// A choice from a small number of options. All options are visible.
//
//   Segmented {
//       options: [{ value: "tile", text: "Tile" }, { value: "scroll", text: "Scroll" }]
//       value: "tile"
//       onPicked: value => settings.mode = value
//   }
FocusScope {
    id: root

    property var options: []
    property var value
    property string label // what the choice is, for a screen reader

    signal picked(var value)

    readonly property bool visualFocus: activeFocus && _keyboard
    property bool _keyboard: false

    function _step(by: int) {
        const at = options.findIndex(option => option.value === value);
        const next = options[(at + by + options.length) % options.length];
        if (next) {
            value = next.value;
            picked(next.value);
        }
    }

    implicitWidth: row.implicitWidth + 6
    implicitHeight: Metrics.controlHeight
    activeFocusOnTab: true

    Accessible.role: Accessible.RadioButton
    Accessible.name: label

    Keys.onLeftPressed: {
        _keyboard = true;
        _step(-1);
    }
    Keys.onRightPressed: {
        _keyboard = true;
        _step(1);
    }
    onActiveFocusChanged: if (!activeFocus)
        _keyboard = false

    Rectangle {
        anchors.fill: parent
        radius: Metrics.radiusControl
        color: Theme.track

        FocusRing {
            target: root
        }
    }

    StretchIndicator {
        anchors.fill: parent
        inset: 3
        target: row.current
    }

    Row {
        id: row

        property Item current: null

        x: 3
        y: 3
        height: parent.height - 6

        Repeater {
            model: root.options

            delegate: Item {
                id: option

                required property var modelData
                readonly property bool on: modelData.value === root.value

                width: text.implicitWidth + 2 * Metrics.padControl
                height: row.height
                onOnChanged: if (on)
                    row.current = option
                Component.onCompleted: if (on)
                    row.current = option

                Text {
                    id: text

                    anchors.centerIn: parent
                    text: option.modelData.text
                    color: option.on ? Theme.ink : Theme.muted
                    font.family: Metrics.fontUi
                    font.pixelSize: Metrics.textLabel
                    font.weight: Metrics.weightStrong

                    Behavior on color {
                        Tint {}
                    }
                }

                TapHandler {
                    onTapped: {
                        root._keyboard = false;
                        root.value = option.modelData.value;
                        root.picked(option.modelData.value);
                    }
                }
            }
        }
    }
}
