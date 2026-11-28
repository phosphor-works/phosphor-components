// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// Surfaces, panels and the leading edge of an indicator.
SpringAnimation {
    spring: Motion.flowSpring
    damping: Motion.flowDamping
    epsilon: 0.01
}
