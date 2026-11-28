// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

pragma Singleton

import QtQuick

// Motion. A position, a size or a shape moves on a spring. Thus a new target during a move keeps
// the velocity. A color or an opacity changes with a fade that has a duration.
//
// There are three springs. Each has an angular frequency (omega, rad/s) and a damping ratio (zeta).
// PhosphorAnimation::Spring uses the same two numbers.
//
//   snap   presses, toggles, small controls
//   flow   surfaces, panels, the leading edge of an indicator
//   trail  the trailing edge of an indicator, content settling
//
// Use them through SnapSpring, FlowSpring and TrailSpring.
QtObject {
    // ── Inputs ──────────────────────────────────────────────────────────────
    property string preset: "fluid" // "calm" (no overshoot), "fluid" or "lively"
    property real slow: 1 // 4 plays everything at a quarter speed
    property bool reduced: false // springs become immediate, fades stay

    readonly property real snapOmega: _omega(30)
    readonly property real snapZeta: _zeta(0.9)
    readonly property real flowOmega: _omega(18)
    readonly property real flowZeta: _zeta(0.8)
    readonly property real trailOmega: _omega(11)
    readonly property real trailZeta: _zeta(1.0)

    // SpringAnimation does not accept omega and zeta. It moves one step each 16 ms. In each step it
    // adds (spring * distance) to the velocity and subtracts (damping * velocity). Then it adds
    // (velocity * 0.016) to the position. That step is large for these springs. The simple
    // conversion is omega^2 * step for the spring, and 2 * zeta * omega * step for the damping. It
    // is 46% too slow and has almost no overshoot. springFor and dampingFor put the poles of that
    // calculation where the continuous spring has them. The measured step response then agrees with
    // omega and zeta. A component that needs a different spring uses these two functions.
    readonly property real _step: 0.016

    function dampingFor(omega: real, zeta: real): real {
        return 1 - Math.exp(-2 * zeta * omega * _step);
    }

    function springFor(omega: real, zeta: real): real {
        const swing = omega * Math.sqrt(Math.abs(1 - zeta * zeta)) * _step;
        const sum = 2 * Math.exp(-zeta * omega * _step) * (zeta < 1 ? Math.cos(swing) : Math.cosh(swing));
        return (2 - dampingFor(omega, zeta) - sum) / _step;
    }

    readonly property real snapSpring: springFor(snapOmega, snapZeta)
    readonly property real snapDamping: dampingFor(snapOmega, snapZeta)
    readonly property real flowSpring: springFor(flowOmega, flowZeta)
    readonly property real flowDamping: dampingFor(flowOmega, flowZeta)
    readonly property real trailSpring: springFor(trailOmega, trailZeta)
    readonly property real trailDamping: dampingFor(trailOmega, trailZeta)

    // Fades. A color appears quickly and disappears slowly.
    readonly property int fade: Math.round(160 * slow)
    readonly property int fadeFast: Math.round(110 * slow)
    readonly property int glowFade: Math.round(900 * slow)

    function _omega(base: real): real {
        return reduced ? 60 : base / slow;
    }

    function _zeta(base: real): real {
        if (reduced || preset === "calm")
            return Math.max(base, 1);
        return preset === "lively" ? base * 0.7 : base;
    }
}
