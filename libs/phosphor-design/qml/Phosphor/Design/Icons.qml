// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

pragma Singleton

import QtQuick

// The set of symbolic icons, as SVG path data on a 24 unit grid. Icon draws them.
//
// An entry is { d, fill, box }. With `fill`, Icon fills the shape and draws no stroke. `box` is [x,
// y, size] for a drawing that is not on the 24 unit grid (the logos).
QtObject {
    readonly property var set: _build()

    function has(name: string): bool {
        return set[name] !== undefined;
    }

    function _circle(cx, cy, r) {
        return `M${cx - r} ${cy}a${r} ${r} 0 1 0 ${2 * r} 0a${r} ${r} 0 1 0 ${-2 * r} 0z`;
    }

    function _rect(x, y, w, h, r) {
        return `M${x + r} ${y}h${w - 2 * r}a${r} ${r} 0 0 1 ${r} ${r}v${h - 2 * r}a${r} ${r} 0 0 1 ${-r} ${r}h${-(w - 2 * r)}a${r} ${r} 0 0 1 ${-r} ${-r}v${-(h - 2 * r)}a${r} ${r} 0 0 1 ${r} ${-r}z`;
    }

    function _build() {
        const c = _circle, r = _rect;
        const stroke = {
            // status
            "wifi": "M3 9a14 14 0 0 1 18 0M6.5 12.5a9 9 0 0 1 11 0M9.5 16a5 5 0 0 1 5 0" + c(12, 19.5, 0.5),
            "wifiOff": "M3 9a14 14 0 0 1 18 0M6.5 12.5a9 9 0 0 1 11 0M9.5 16a5 5 0 0 1 5 0M4 3l17 18",
            "bluetooth": "M7 7l10 10-5 4V3l5 4L7 17",
            "moon": "M20 15A9 9 0 0 1 9 4a9 9 0 1 0 11 11Z",
            "sun": c(12, 12, 4) + "M12 2v2M12 20v2M2 12h2M20 12h2M5 5l1.5 1.5M17.5 17.5L19 19M5 19l1.5-1.5M17.5 6.5L19 5",
            "bulb": "M9 18h6M10 21h4M12 3a6 6 0 0 0-4 10.5c.7.7 1 1.5 1 2.5h6c0-1 .3-1.8 1-2.5A6 6 0 0 0 12 3Z",
            "volume": "M4 9h4l5-4v14l-5-4H4zM16.5 9.5a3.5 3.5 0 0 1 0 5M19 7a7.5 7.5 0 0 1 0 10",
            "volumeLow": "M4 9h4l5-4v14l-5-4H4zM16.5 9.5a3.5 3.5 0 0 1 0 5",
            "volumeMute": "M4 9h4l5-4v14l-5-4H4zM17 9.5l4 5M21 9.5l-4 5",
            "battery": r(2, 7, 18, 10, 3) + "M23 10.5v3M6 11v2M9.5 11v2M13 11v2",
            "bell": "M5 10a7 7 0 0 1 14 0v5l2 3H3l2-3ZM10 21h4",
            "bellOff": "M5 10a7 7 0 0 1 14 0v5l2 3H3l2-3ZM10 21h4M4 3l17 18",
            "power": "M12 2v10M6 5a9 9 0 1 0 12 0",
            "lock": r(5, 10, 14, 11, 3) + "M8 10V7a4 4 0 0 1 8 0v3",
            "sleep": "M4 11h6l-6 8h6M14 4h6l-6 8h6",
            "restart": "M20 12a8 8 0 1 1-2.5-5.8M20 3v5h-5",
            "logout": "M10 4H5v16h5M15 8l4 4-4 4M9 12h10",
            // navigation and actions
            "search": c(10, 10, 7) + "M15 15l6 6",
            "chevronRight": "M9 6l6 6-6 6",
            "chevronLeft": "M15 6l-6 6 6 6",
            "chevronDown": "M6 9l6 6 6-6",
            "back": "M20 12H5M11 6l-6 6 6 6",
            "send": "M5 12h14M13 6l6 6-6 6",
            "check": "M5 12l4 4L19 6",
            "close": "M6 6l12 12M18 6L6 18",
            "minimize": "M6 12h12",
            "maximize": r(6, 6, 12, 12, 2.5),
            "plus": "M12 5v14M5 12h14",
            "tune": "M4 7h10M18 7h2M4 17h2M10 17h10" + c(16, 7, 2) + c(8, 17, 2),
            // placement
            "zones": r(3, 3, 8, 18, 2) + r(14, 3, 7, 8, 2) + r(14, 14, 7, 7, 2),
            "tiling": r(3, 4, 18, 16, 3) + "M12 4v16M12 12h9",
            "scrolling": r(8, 4, 8, 16, 2) + "M3 7v10M21 7v10",
            "bar": r(3, 4, 18, 5, 2.5) + r(3, 13, 18, 7, 2.5),
            // apps and objects
            "drop": "M12 3s6 6.2 6 10.5a6 6 0 0 1-12 0C6 9.2 12 3 12 3Z",
            "terminal": r(2, 4, 20, 16, 3) + "M6 9l3 3-3 3M12 15h4",
            "globe": c(12, 12, 9) + "M12 3a4 9 0 0 1 0 18a4 9 0 0 1 0-18M3 12h18",
            "folder": "M3 6h7l2 3h9v11H3z",
            "file": "M6 3h8l4 4v14H6zM14 3v4h4",
            "edit": "M4 20h4L19 9l-4-4L4 16Z",
            "music": "M9 18V5l11-2v13" + c(6, 18, 3) + c(17, 16, 3),
            "image": r(3, 4, 18, 16, 3) + c(8.5, 9.5, 1.5) + "M4 17l5-5 4 4 3-3 4 4",
            "clock": c(12, 12, 9) + "M12 7v5l3 2",
            "tray": "M4 13l2-8h12l2 8v6H4zM4 13h5l1 2h4l1-2h5",
            "chat": "M4 5h16v11H9l-5 4z",
            "game": "M7 8h10a4 4 0 0 1 4 4l-1 5a2 2 0 0 1-3 1l-2-3H9l-2 3a2 2 0 0 1-3-1l-1-5a4 4 0 0 1 4-4zM8 11v3M6.5 12.5h3M16 12.5h.5",
            "cloud": "M7 18a4 4 0 0 1-.5-8A6 6 0 0 1 18 9.5a4.3 4.3 0 0 1-.5 8.5Z",
            "phone": r(7, 2, 10, 20, 2.5) + "M11 18h2",
            "record": c(12, 12, 9) + c(12, 12, 3.5),
            "key": c(8, 15, 4) + "M11 12l9-9M16 7l3 3",
            "sync": "M20 12a8 8 0 0 0-14-5M4 4v4h4M4 12a8 8 0 0 0 14 5M20 20v-4h-4",
            "download": "M12 4v11M7 10l5 5 5-5M5 20h14",
            "user": c(12, 8, 4) + "M4 21a8 8 0 0 1 16 0",
            // hardware
            "chip": r(6, 6, 12, 12, 2) + "M9 2v4M15 2v4M9 18v4M15 18v4M2 9h4M2 15h4M18 9h4M18 15h4",
            "gpu": r(2, 7, 20, 10, 2) + c(8, 12, 2.2) + "M14 10h4M6 17v3M10 17v3",
            "memory": r(3, 8, 18, 8, 1.5) + "M7 16v3M12 16v3M17 16v3M7 11v2M12 11v2M17 11v2",
            "network": "M7 20V5M3 9l4-4 4 4M17 4v15M13 15l4 4 4-4",
            "disk": "M4 14l2-9h12l2 9v5H4zM4 14h16M16 17h1",
            "keyboard": r(2, 6, 20, 12, 3) + "M6 10h1M10 10h1M14 10h1M18 10h.5M7 14h10",
            "capsLock": "M12 4l7 8h-4v4H9v-4H5ZM9 20h6",
            "microphone": r(9, 3, 6, 11, 3) + "M5 11a7 7 0 0 0 14 0M12 18v3",
            "headphones": "M4 15v-3a8 8 0 0 1 16 0v3" + r(3, 14, 4, 6, 1.5) + r(17, 14, 4, 6, 1.5),
            "screen": r(3, 4, 18, 12, 2) + "M9 20h6M12 16v4",
            "mouse": r(7, 3, 10, 18, 5) + "M12 7v3"
        };
        const fill = {
            "play": "M8 5v14l11-7Z",
            "pause": r(7, 5, 3.5, 14, 1) + r(13.5, 5, 3.5, 14, 1),
            "previous": "M19 5v14L9 12ZM5 5h2.5v14H5z",
            "next": "M5 5v14l10-7ZM16.5 5H19v14h-2.5z"
        };
        const marks = {
            "phosphor": {
                "box": [206, 206, 612],
                "d": "M583 358L598 362L612 367L626 374L639 381L652 389L664 398L676 408L686 419L695 431L703 444L709 458L714 472L716 487L714 502L702 516L689 504L685 492L681 480L678 469L674 457L669 446L664 434L658 423L650 412L641 401L632 391L621 382L609 373L597 365L583 358ZM696 553L706 571L704 588L698 603L690 618L680 631L668 643L654 653L640 661L624 669L608 674L592 678L575 681L559 682L541 676L555 665L569 658L582 651L594 643L605 635L616 626L626 617L635 607L643 598L652 589L660 579L668 570L678 560L696 553ZM483 676L465 682L449 681L432 678L416 674L400 669L384 661L370 653L356 643L344 631L334 618L326 603L320 588L318 571L328 553L346 560L356 570L364 579L372 589L381 598L389 607L398 617L408 626L419 635L430 643L442 651L455 658L469 665L483 676ZM322 516L310 502L308 487L310 472L315 458L321 444L329 431L338 419L348 408L360 398L372 389L385 381L398 374L412 367L426 362L441 358L427 365L415 373L403 382L392 391L383 401L374 412L366 423L360 434L355 446L350 457L346 469L343 480L339 492L335 504L322 516ZM512 206C540 372 540 652 512 818C484 652 484 372 512 206Z"
            },
            "facet": {
                "box": [240, 240, 544],
                "d": "M554.7 408.9L615.1 469.3L615.1 554.7L554.7 615.1L469.3 615.1L408.9 554.7L408.9 469.3L469.3 408.9ZM469.3 392.2L512 250.5L554.7 392.2ZM566.5 397.1L696.9 327.1L626.9 457.5ZM631.8 469.3L773.5 512L631.8 554.7ZM626.9 566.5L696.9 696.9L566.5 626.9ZM554.7 631.8L512 773.5L469.3 631.8ZM457.5 626.9L327.1 696.9L397.1 566.5ZM392.2 554.7L250.5 512L392.2 469.3ZM397.1 457.5L327.1 327.1L457.5 397.1Z"
            },
            "afterglow": {
                "box": [222, 222, 580],
                "d": "M512 230C484 410 394 650 286 794C336 614 424 374 512 230ZM512 230C600 374 688 614 738 794C630 650 540 410 512 230ZM298 486C340 564 416 600 492 604C478 620 466 628 450 626C372 616 312 566 298 486ZM532 604C608 600 684 564 726 486C712 566 652 616 574 626C558 628 546 620 532 604Z"
            }
        };
        const out = {};
        for (const name in stroke)
            out[name] = {
                "d": stroke[name],
                "fill": false,
                "box": [0, 0, 24]
            };
        for (const name in fill)
            out[name] = {
                "d": fill[name],
                "fill": true,
                "box": [0, 0, 24]
            };
        for (const name in marks)
            out[name] = {
                "d": marks[name].d,
                "fill": true,
                "box": marks[name].box
            };
        return out;
    }
}
