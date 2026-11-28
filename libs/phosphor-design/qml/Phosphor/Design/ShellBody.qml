// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

// The shell body: the bar, and the panel that opens from the bar, as one shape.
//
// A panel is not a popup next to the bar. Set `source` to the control that opens the panel, and set
// `open` to true. The shell body then opens a drawer below that control and connects it to the bar
// with a fillet. If `source` or the content size changes while the drawer is open, the same drawer
// moves and changes size. It does not close.
//
//   ShellBody {
//       anchors.fill: parent
//       source: statusChip
//       contentWidth: panel.width
//       contentHeight: panel.implicitHeight
//       open: true
//       barContent: Row { ... }   // the chips
//       QuickSettings { id: panel }
//   }
//
// The edge has the spectrum. No other item in the shell has it. The edge becomes bright when the
// shell body changes shape, and the glow fades in `Motion.glowFade`.
Item {
    id: root

    // ── The bar ─────────────────────────────────────────────────────────────
    property rect bar: Qt.rect(12, 10, width - 24, Metrics.barHeight)
    property alias barContent: barHost.data

    // ── The drawer ──────────────────────────────────────────────────────────
    property Item source
    property real contentWidth: 0
    property real contentHeight: 0
    property bool open: false
    property bool fused: true // false floats the drawer below the bar instead
    default property alias content: host.data

    // The brightness of the edge, from 0 to 1. It goes up when the shape changes, and then it
    // fades.
    property real energy: 0

    readonly property real drawerHeight: Math.max(0, _h)
    readonly property real _edge: 30 // a drawer keeps this far from the bar's ends, so both fillets fit
    property real _x: 0
    property real _w: 0
    property real _h: 0
    property bool _jump: false
    readonly property string _outline: _path(0)

    function pulse(amount: real) {
        glowFade.stop();
        energy = Math.max(energy, amount);
        glowFade.start();
    }

    function _sync() {
        if (!source)
            return;
        const at = root.mapFromItem(source, 0, 0);
        if (open) {
            // A drawer that opens from the closed state starts at the source. There is no earlier
            // position to move from.
            if (_h < 0.5) {
                _jump = true;
                _x = at.x;
                _w = source.width;
                _h = 0;
                _jump = false;
            }
            const least = bar.x + _edge;
            const most = bar.x + bar.width - _edge - contentWidth;
            _w = contentWidth;
            _x = Math.max(least, Math.min(most, at.x + source.width / 2 - contentWidth / 2));
            _h = contentHeight;
        } else {
            _x = at.x;
            _w = source.width;
            _h = 0;
        }
    }

    // The outline, clockwise from the top left of the bar. `inset` makes the outline smaller by the
    // same distance on each side. The rim is the area between the outline and the inset outline.
    // Thus the fill below the rim can be glass.
    function _path(inset: real): string {
        const arc = (r, sweep, x, y) => r > 0.05 ? `A${r} ${r} 0 0 ${sweep} ${x} ${y}` : `L${x} ${y}`;
        const convex = r => Math.max(0, r - inset);
        const outerL = bar.x, outerR = bar.x + bar.width, outerB = bar.y + bar.height;
        const L = outerL + inset, T = bar.y + inset, R = outerR - inset, B = outerB - inset;
        const barRadius = Math.min(Metrics.corners, bar.height / 2);
        const r = convex(barRadius);
        const dh = Math.max(0, _h), dw = Math.max(0, _w);
        const big = Metrics.radiusSurface;
        let d = `M${L + r} ${T}H${R - r}${arc(r, 1, R, T + r)}`;
        if (!fused || dh < 0.5 || dw < 2 * inset + 1) {
            d += `V${B - r}${arc(r, 1, R - r, B)}H${L + r}${arc(r, 1, L, B - r)}`;
        } else {
            const xl = _x, xr = _x + dw, bottom = outerB + dh - inset;
            const gapR = Math.max(0, outerR - xr), gapL = Math.max(0, xl - outerL);
            const cornerR = convex(Math.min(barRadius, gapR / 2)), cornerL = convex(Math.min(barRadius, gapL / 2));
            const filletR = Math.min(big * 0.8, gapR / 2, dh / 2), filletL = Math.min(big * 0.8, gapL / 2, dh / 2);
            const foot = convex(Math.min(big, dh / 2, dw / 2));
            d += `V${B - cornerR}${arc(cornerR, 1, R - cornerR, B)}`;
            // A concave fillet keeps its center, so an inset increases its radius.
            d += filletR > 0.05 ? `H${xr + filletR}A${filletR + inset} ${filletR + inset} 0 0 0 ${xr - inset} ${outerB + filletR}` : `H${xr - inset}`;
            d += `V${bottom - foot}${arc(foot, 1, xr - inset - foot, bottom)}H${xl + inset + foot}${arc(foot, 1, xl + inset, bottom - foot)}`;
            d += filletL > 0.05 ? `V${outerB + filletL}A${filletL + inset} ${filletL + inset} 0 0 0 ${xl - filletL} ${B}` : `V${B}`;
            d += `H${L + cornerL}${arc(cornerL, 1, L, B - cornerL)}`;
        }
        d += `V${T + r}${arc(r, 1, L + r, T)}Z`;
        if (!fused && dh >= 1 && dw > 2 * inset + 1) {
            const top = outerB + Metrics.surfaceGap + inset, bottom = outerB + Metrics.surfaceGap + dh - inset;
            const xl = _x + inset, xr = _x + dw - inset;
            const foot = convex(Math.min(big, dh / 2, dw / 2));
            d += `M${xl + foot} ${top}H${xr - foot}${arc(foot, 1, xr, top + foot)}V${bottom - foot}${arc(foot, 1, xr - foot, bottom)}H${xl + foot}${arc(foot, 1, xl, bottom - foot)}V${top + foot}${arc(foot, 1, xl + foot, top)}Z`;
        }
        return d;
    }

    onOpenChanged: {
        _sync();
        pulse(open ? 1 : 0.5);
    }
    onSourceChanged: if (open) {
        _sync();
        pulse(1);
    }
    onContentWidthChanged: if (open)
        _sync()
    onContentHeightChanged: if (open)
        _sync()
    onBarChanged: Qt.callLater(_sync)
    onFusedChanged: pulse(0.8)

    NumberAnimation {
        id: glowFade

        target: root
        property: "energy"
        to: 0
        duration: Motion.glowFade
        easing.type: Easing.OutCubic
    }

    Behavior on _x {
        enabled: !root._jump

        FlowSpring {
            epsilon: 0.05
        }
    }
    Behavior on _w {
        enabled: !root._jump

        FlowSpring {
            epsilon: 0.05
        }
    }
    // The height follows the width with a small delay. Thus a drawer becomes wide and then becomes
    // high.
    Behavior on _h {
        enabled: !root._jump

        SpringAnimation {
            spring: Motion.springFor(Motion.flowOmega * 0.85, Motion.flowZeta)
            damping: Motion.dampingFor(Motion.flowOmega * 0.85, Motion.flowZeta)
            epsilon: 0.05
        }
    }

    // The glow: the same outline with a blur, behind the shell body.
    Shape {
        id: halo

        anchors.fill: parent
        visible: Theme.glow && root.energy > 0.01
        opacity: root.energy * 0.75
        layer.enabled: visible
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1
            blurMax: 28
            autoPaddingEnabled: true
        }

        ShapePath {
            strokeColor: "transparent"
            fillGradient: LinearGradient {
                x1: root.bar.x
                x2: root.bar.x + root.bar.width
                y1: 0
                y2: 0

                GradientStop {
                    position: 0
                    color: Theme.spectrum[0]
                }
                GradientStop {
                    position: 0.34
                    color: Theme.spectrum[1]
                }
                GradientStop {
                    position: 0.68
                    color: Theme.spectrum[2]
                }
                GradientStop {
                    position: 1
                    color: Theme.spectrum[3]
                }
            }

            PathSvg {
                path: root._outline
            }
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: "transparent"
            fillColor: Theme.shellSurface

            PathSvg {
                path: root._outline
            }
        }

        // The rim. It is dim when the shell body does not change, and bright while the shell body
        // changes shape.
        ShapePath {
            id: rim

            readonly property real strength: 0.38 + 0.6 * root.energy

            strokeColor: "transparent"
            fillRule: ShapePath.OddEvenFill
            fillGradient: LinearGradient {
                x1: root.bar.x
                x2: root.bar.x + root.bar.width
                y1: 0
                y2: 0

                GradientStop {
                    position: 0
                    color: Theme.tint(Theme.spectrum[0], rim.strength)
                }
                GradientStop {
                    position: 0.34
                    color: Theme.tint(Theme.spectrum[1], rim.strength)
                }
                GradientStop {
                    position: 0.68
                    color: Theme.tint(Theme.spectrum[2], rim.strength)
                }
                GradientStop {
                    position: 1
                    color: Theme.tint(Theme.spectrum[3], rim.strength)
                }
            }

            PathSvg {
                path: root._outline + root._path(Metrics.rimWidth)
            }
        }
    }

    Item {
        id: barHost

        x: root.bar.x
        y: root.bar.y
        width: root.bar.width
        height: root.bar.height
    }

    // The drawer shows its content through this item. The content keeps its full width and stays
    // centered while this item changes shape.
    Item {
        x: root._x
        y: root.bar.y + root.bar.height + (root.fused ? 0 : Metrics.surfaceGap)
        width: Math.max(0, root._w)
        height: Math.max(0, root._h)
        clip: true

        Item {
            id: host

            x: (parent.width - width) / 2
            width: root.contentWidth
            height: root.contentHeight
        }
    }
}
