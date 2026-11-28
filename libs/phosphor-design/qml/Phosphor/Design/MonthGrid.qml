// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T

// One month as a grid of days. The week starts on Monday.
//
// Today has the accent fill. The selected day has the selection tint. A day in `marked` has a dot
// below its number, for a day with an event. The days of the adjacent months are dim.
//
// A month is a number from 0, as in a JavaScript Date. Thus 8 is September.
//
//   MonthGrid {
//       year: 2026
//       month: 8
//       marked: [14, 17, 21]
//       onPicked: date => agenda.date = date
//   }
Item {
    id: root

    property int year: new Date().getFullYear()
    property int month: new Date().getMonth()
    property date today: new Date()
    property date selected: today
    property var marked: [] // days of this month, from 1

    signal picked(date date)

    readonly property real cell: Math.floor(width / 7)
    // The first cell of the grid: the Monday on or before day 1.
    readonly property date _origin: {
        const first = new Date(year, month, 1);
        const back = (first.getDay() + 6) % 7;
        return new Date(year, month, 1 - back);
    }
    readonly property int _weeks: {
        const days = new Date(year, month + 1, 0).getDate();
        const back = (new Date(year, month, 1).getDay() + 6) % 7;
        return Math.ceil((back + days) / 7);
    }

    function _same(a: date, b: date): bool {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }

    implicitWidth: 7 * 36
    implicitHeight: weekdays.height + _weeks * cell

    Row {
        id: weekdays

        height: Metrics.lineCaption + Metrics.space8

        Repeater {
            model: 7

            Text {
                required property int index

                width: root.cell
                horizontalAlignment: Text.AlignHCenter
                // The locale gives Sunday the number 0, and the grid starts on Monday.
                text: Qt.locale().standaloneDayName((index + 1) % 7, Locale.NarrowFormat)
                color: Theme.muted
                font.family: Metrics.fontUi
                font.pixelSize: Metrics.textCaption
                font.weight: Metrics.weightBody
            }
        }
    }

    Grid {
        anchors.top: weekdays.bottom
        columns: 7

        Repeater {
            model: root._weeks * 7

            T.AbstractButton {
                id: day

                required property int index
                readonly property date date: new Date(root._origin.getFullYear(), root._origin.getMonth(), root._origin.getDate() + index)
                readonly property bool inMonth: date.getMonth() === root.month
                readonly property bool isToday: root._same(date, root.today)
                readonly property bool isSelected: root._same(date, root.selected)

                width: root.cell
                height: root.cell

                Accessible.name: date.toLocaleDateString(Qt.locale(), Locale.LongFormat)

                onClicked: root.picked(date)

                contentItem: Item {
                    Text {
                        anchors.centerIn: parent
                        text: day.date.getDate()
                        color: day.isToday ? Theme.ink : Theme.text
                        opacity: day.inMonth ? 1 : 0.3
                        font.family: Metrics.fontUi
                        font.pixelSize: Metrics.textBody
                        font.weight: day.isToday ? Metrics.weightStrong : Metrics.weightBody
                        font.features: {
                            "tnum": 1
                        }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Metrics.space4
                        width: 4
                        height: 4
                        radius: 2
                        visible: day.inMonth && root.marked.includes(day.date.getDate())
                        color: day.isToday ? Theme.ink : Theme.accent
                    }
                }

                background: Item {
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Metrics.space2
                        // Today is on, so it is rounder than a day that is only selected.
                        radius: day.isToday ? height / 2 : Metrics.radiusControl
                        color: day.isToday ? Theme.accent : day.isSelected ? Theme.selected : day.hovered ? Theme.hover : "transparent"
                        scale: day.down ? Metrics.pressScaleSmall : 1

                        Behavior on color {
                            Tint {}
                        }
                        Behavior on scale {
                            SnapSpring {
                                epsilon: 0.002
                            }
                        }

                        FocusRing {
                            target: day
                            around: parent.radius
                        }
                    }
                }
            }
        }
    }
}
