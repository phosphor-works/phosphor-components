// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Shapes

// The sound that plays, as a picture of its spectrum. There are three styles: `bars`, `ribbon` and
// `halo`.
//
// Set `levels` to the spectrum of the audio, as values from 0 to 1 with the low frequencies first.
// Without `levels`, the item shows a signal that it makes itself, so that a design has motion. When
// `running` is false, the picture becomes low and stops. Thus the picture shows "playing" and
// "paused".
//
// The picture has the colors of the spectrum. The visualizer, the edge of ShellBody and the logos
// are the only items that use the full spectrum.
//
//   Visualizer { levels: audio.spectrum; running: player.playing; style: "ribbon" }
Item {
    id: root

    property var levels: []
    property bool running: true
    // False keeps the signal that the item makes at one moment, for a picture that must not change.
    property bool animated: true
    property string style: "bars"
    property int count: 32
    property var colors: Theme.spectrum

    // The time of the signal that the item makes, in seconds.
    property real phase: 1.8
    readonly property bool _live: running && animated && visible && levels.length === 0 && !Motion.reduced
    readonly property real _strength: running ? 1 : 0.12
    // One level for each bar or point, from 0 to 1.
    readonly property var shown: {
        const values = [];
        for (let i = 0; i < count; ++i) {
            const x = count > 1 ? i / (count - 1) : 0;
            const level = levels.length > 0 ? levels[Math.min(levels.length - 1, Math.floor(x * levels.length))] : _signal(x, phase);
            values.push(Math.max(0, Math.min(1, level * _strength)));
        }
        return values;
    }

    // A signal with a strong bass and weaker middle frequencies, which moves with the time.
    function _signal(x: real, time: real): real {
        const bass = Math.exp(-Math.pow((x - 0.2) / 0.17, 2));
        const mids = Math.exp(-Math.pow((x - 0.57) / 0.23, 2));
        const pulse = 0.5 + 0.5 * Math.sin(time * 3.5);
        return (0.12 + bass * (0.3 + pulse * 0.3) + mids * 0.28) * (0.66 + 0.2 * Math.sin(x * 32 - time * 4) + 0.14 * Math.sin(x * 63 + time * 2)) * 1.5;
    }

    // The color at a position from 0 to 1 across the spectrum.
    function colorAt(position: real): color {
        const last = colors.length - 1;
        if (last < 1)
            return colors.length === 1 ? colors[0] : Theme.accent;
        const scaled = Math.max(0, Math.min(1, position)) * last;
        const index = Math.min(last - 1, Math.floor(scaled));
        const mix = scaled - index;
        const a = colors[index], b = colors[index + 1];
        return Qt.rgba(a.r + (b.r - a.r) * mix, a.g + (b.g - a.g) * mix, a.b + (b.b - a.b) * mix, 1);
    }

    implicitWidth: 240
    implicitHeight: 64

    Accessible.role: Accessible.Graphic

    Timer {
        interval: 33
        repeat: true
        running: root._live
        onTriggered: root.phase += 0.033 / Motion.slow
    }

    Loader {
        anchors.fill: parent
        sourceComponent: root.style === "ribbon" ? ribbon : root.style === "halo" ? halo : bars
    }

    Component {
        id: bars

        Item {
            id: field

            readonly property real step: width / root.count

            Repeater {
                model: root.count

                Rectangle {
                    required property int index

                    x: index * field.step
                    width: Math.max(1, field.step - (field.step > 5 ? 2 : 1))
                    height: Math.max(2, root.shown[index] * field.height)
                    y: field.height - height
                    radius: Math.min(2, width / 2)
                    color: root.colorAt(root.count > 1 ? index / (root.count - 1) : 0)

                    // A level from real audio changes in steps, and the spring makes the bar move
                    // between them. The signal of the item is smooth without a spring.
                    Behavior on height {
                        enabled: root.levels.length > 0 || !root.running

                        TrailSpring {}
                    }
                }
            }
        }
    }

    Component {
        id: ribbon

        Shape {
            id: band

            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: "transparent"
                fillGradient: LinearGradient {
                    x1: 0
                    y1: 0
                    x2: band.width
                    y2: 0

                    GradientStop {
                        position: 0
                        color: root.colorAt(0)
                    }
                    GradientStop {
                        position: 0.33
                        color: root.colorAt(0.33)
                    }
                    GradientStop {
                        position: 0.67
                        color: root.colorAt(0.67)
                    }
                    GradientStop {
                        position: 1
                        color: root.colorAt(1)
                    }
                }

                PathSvg {
                    // The band is the levels above the center line and the same levels below it.
                    path: {
                        const middle = band.height / 2;
                        const step = root.count > 1 ? band.width / (root.count - 1) : band.width;
                        const half = level => Math.max(1, level * band.height / 2);
                        let top = "", bottom = "";
                        for (let i = 0; i < root.count; ++i) {
                            const x = (i * step).toFixed(1);
                            top += `${i === 0 ? "M" : "L"}${x} ${(middle - half(root.shown[i])).toFixed(1)}`;
                            bottom = `L${x} ${(middle + half(root.shown[i])).toFixed(1)}` + bottom;
                        }
                        return top + bottom + "Z";
                    }
                }
            }
        }
    }

    Component {
        id: halo

        Item {
            id: ring

            readonly property real inner: Math.min(width, height) * 0.24

            Repeater {
                model: root.count

                Item {
                    required property int index

                    x: ring.width / 2
                    y: ring.height / 2
                    rotation: 360 * index / root.count

                    Rectangle {
                        x: -1
                        y: -ring.inner - height
                        width: 2
                        height: Math.max(2, root.shown[index] * ring.inner * 1.6)
                        radius: 1
                        color: root.colorAt(index < root.count / 2 ? 2 * index / root.count : 2 - 2 * index / root.count)
                    }
                }
            }
        }
    }
}
