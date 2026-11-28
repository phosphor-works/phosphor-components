// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// Presses, toggles and small controls.
SpringAnimation {
    spring: Motion.snapSpring
    damping: Motion.snapDamping
    epsilon: 0.01
}
