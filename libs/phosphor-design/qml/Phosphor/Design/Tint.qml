// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick

// A color that changes with a state. A color changes with a fade and not with a spring.
ColorAnimation {
    duration: Motion.fade
    easing.type: Easing.OutCubic
}
