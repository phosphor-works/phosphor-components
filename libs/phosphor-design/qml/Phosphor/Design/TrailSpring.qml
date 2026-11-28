// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// The trailing edge of an indicator, and content that follows its surface.
SpringAnimation {
    spring: Motion.trailSpring
    damping: Motion.trailDamping
    epsilon: 0.01
}
