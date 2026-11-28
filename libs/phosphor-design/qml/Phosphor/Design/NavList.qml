// SPDX-FileCopyrightText: 2026 Phosphor Works Team
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Templates as T

// The list in a sidebar. It contains pages, and categories that contain pages.
//
//   NavList {
//       model: [
//           { text: "Placement", children: [{ id: "tiling", text: "Tiling", icon: "tiling" }] },
//           { id: "about", text: "About" }
//       ]
//       current: "tiling"
//       onPicked: id => controller.currentPageId = id
//   }
//
// An entry with `children` is a category. Its header opens and closes it. Its pages have an indent
// of one step, and a chevron shows the state. When a closed category contains the current page, its
// header shows the selection. Thus the list always shows the position of the user.
//
// `filter` shows only the pages whose name contains it. A filter opens each category, because a
// closed category hides a result.
//
// A page with a `count` shows that number as a badge. An entry with `divider: true` is a line
// between two groups. `compact` makes the list a column of icons for a narrow window. The
// categories then go away, and a page with no icon shows its first letter.
//
// An entry with `children` and `drill: true` is a parent with a list of its own. Its row replaces
// the list with that list, and a row at the top goes back. `scope` is the parent that the list
// shows. The list changes `scope` to show the current page. A parent can have an `id`. It is then
// also a page, and its row opens that page. A filter searches each list at the same time.
//
//   { text: "Snapping", icon: "zones", drill: true, children: [{ id: "zones", text: "Zones" }] }
Item {
    id: root

    property var model: []
    property string current
    property string filter
    property var collapsed: [] // the `text` of each closed category
    property bool compact: false
    // The `id` of the drill parent that the list shows, or its `text` when it has no `id`. Empty
    // shows the top list.
    property string scope

    signal picked(string id)

    readonly property string _needle: filter.trim().toLowerCase()
    property Item _marked: null
    property bool _ready: false
    property bool _started: false
    // The scope that the list shows now. It follows `scope` after the old list fades out.
    property string _shown
    readonly property var _scopeEntry: _shown === "" ? null : _find(model, entry => _isDrill(entry) && _key(entry) === _shown)
    readonly property var _searchModel: _flat(model)
    readonly property var _entries: _needle !== "" ? _searchModel : _scopeEntry ? _scopeEntry.children : model

    // Shows the list of a drill parent.
    function enter(key: string) {
        scope = key;
    }

    // Goes back to the list that contains the drill parent.
    function leave() {
        const above = _trail(model, entry => _isDrill(entry) && _key(entry) === scope, []);
        scope = above && above.length > 0 ? _key(above[above.length - 1]) : "";
    }

    function _key(entry: var): string {
        return entry.id ?? entry.text ?? "";
    }

    function _isDrill(entry: var): bool {
        return entry.drill === true && entry.children !== undefined;
    }

    function _find(entries: var, match: var): var {
        for (const entry of entries) {
            if (match(entry))
                return entry;
            const below = entry.children !== undefined ? _find(entry.children, match) : null;
            if (below)
                return below;
        }
        return null;
    }

    // The drill parents above the first entry that matches, from the top down. Null when no entry
    // matches.
    function _trail(entries: var, match: var, above: var): var {
        for (const entry of entries) {
            if (match(entry))
                return above;
            if (entry.children === undefined)
                continue;
            const found = _trail(entry.children, match, _isDrill(entry) ? above.concat([entry]) : above);
            if (found)
                return found;
        }
        return null;
    }

    function _holds(entry: var, id: string): bool {
        return entry.children.some(child => child.id === id || (child.children !== undefined && _holds(child, id)));
    }

    // The scope that shows the page `id`.
    function _scopeFor(id: string): string {
        const page = _find(model, entry => entry.id === id);
        if (!page)
            return scope;
        if (_isDrill(page))
            return _key(page);
        const above = _trail(model, entry => entry.id === id, []);
        return above.length > 0 ? _key(above[above.length - 1]) : "";
    }

    // The model for a search. A drill parent becomes a category of its pages, and the categories
    // below it follow. A model with no drill parent stays the same object, so that its rows stay.
    function _flat(entries: var): var {
        if (!entries.some(entry => _isDrill(entry)))
            return entries;
        let out = [];
        for (const entry of entries) {
            if (!_isDrill(entry)) {
                out.push(entry);
                continue;
            }
            const own = entry.id !== undefined ? [
                {
                    "id": entry.id,
                    "text": entry.text,
                    "icon": entry.icon,
                    "count": entry.count
                }
            ] : [];
            out.push({
                "text": entry.text,
                "children": own.concat(entry.children.filter(child => child.children === undefined && child.divider !== true))
            });
            out = out.concat(_flat(entry.children.filter(child => child.children !== undefined)));
        }
        return out;
    }

    function _swap() {
        const deeper = swap.deeper;
        _shown = scope;
        _jump = true;
        sheet.x = deeper ? Metrics.space24 : -Metrics.space24;
        _jump = false;
        sheet.x = 0;
        Qt.callLater(indicator.reposition);
    }

    property bool _jump: false

    function toggle(category: string) {
        const next = collapsed.slice();
        const at = next.indexOf(category);
        if (at >= 0)
            next.splice(at, 1);
        else
            next.push(category);
        collapsed = next;
    }

    function _matches(text: string): bool {
        return _needle === "" || text.toLowerCase().includes(_needle);
    }

    implicitWidth: compact ? Metrics.navRowHeight + Metrics.space12 : 220
    implicitHeight: column.height

    // No item animates during the first layout of the list.
    Component.onCompleted: {
        if (scope === "")
            scope = _scopeFor(current);
        _started = true;
        Qt.callLater(() => root._ready = true);
    }
    // The values that the owner sets at the start stay.
    onCurrentChanged: if (_started)
        scope = _scopeFor(current)
    onScopeChanged: {
        if (!_ready) {
            _shown = scope;
            return;
        }
        // A list below the list that shows now comes in from the right.
        const above = _trail(model, entry => _isDrill(entry) && _key(entry) === scope, []);
        swap.deeper = scope !== "" && above !== null && (_shown === "" || above.some(entry => _key(entry) === _shown));
        swap.restart();
    }

    // The old list fades out. The new list then comes in from the side.
    SequentialAnimation {
        id: swap

        property bool deeper: true

        Fade {
            target: sheet
            property: "opacity"
            to: 0
            duration: Motion.fadeFast
        }
        ScriptAction {
            script: root._swap()
        }
        Fade {
            target: sheet
            property: "opacity"
            to: 1
        }
    }

    component Row: T.AbstractButton {
        id: row

        property string iconName // `icon` belongs to the button template
        property int depth: 0
        property bool isCurrent: false
        property bool isCategory: false
        property bool isDrill: false
        property bool heading: false // the back row has the text color, as a category has
        property bool expanded: false
        property int count: 0

        width: parent ? parent.width : 0
        implicitHeight: Metrics.navRowHeight
        leftPadding: root.compact ? (width - Metrics.iconSmall) / 2 : Metrics.padRow + depth * Metrics.navIndent
        rightPadding: root.compact ? leftPadding : Metrics.space8

        Accessible.name: text

        contentItem: Item {
            Icon {
                id: glyph

                anchors.verticalCenter: parent.verticalCenter
                visible: row.iconName !== ""
                name: row.iconName
                size: Metrics.iconSmall
                color: row.isCurrent ? Theme.accent : label.color

                Behavior on color {
                    Tint {}
                }
            }

            // In the compact list, a page with no icon shows its first letter.
            Text {
                anchors.centerIn: parent
                visible: root.compact && row.iconName === ""
                text: row.text.charAt(0).toUpperCase()
                color: row.isCurrent ? Theme.accent : label.color
                font.family: Metrics.fontUi
                font.pixelSize: Metrics.textBody
                font.weight: Metrics.weightStrong
            }

            Text {
                id: label

                anchors.left: glyph.visible ? glyph.right : parent.left
                anchors.leftMargin: glyph.visible ? 11 : 0
                anchors.right: tally.visible ? tally.left : chevron.visible ? chevron.left : parent.right
                anchors.rightMargin: chevron.visible || tally.visible ? 6 : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: !root.compact
                text: row.text
                elide: Text.ElideRight
                color: row.isCurrent || row.hovered || row.isCategory || row.heading ? Theme.text : Theme.muted
                font.family: Metrics.fontUi
                font.pixelSize: Metrics.textBody
                font.weight: Metrics.weightStrong

                Behavior on color {
                    Tint {}
                }
            }

            Icon {
                id: chevron

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: (row.isCategory || row.isDrill) && !root.compact
                name: "chevronRight"
                size: Metrics.iconSmall
                color: Theme.muted
                rotation: row.isCategory && row.expanded ? 90 : 0

                Behavior on rotation {
                    enabled: root._ready

                    FlowSpring {}
                }
            }

            // The compact list has no space for a number, so the badge is a dot at the icon.
            Badge {
                id: tally

                anchors.right: chevron.visible ? chevron.left : parent.right
                anchors.rightMargin: root.compact ? -Metrics.space6 : chevron.visible ? Metrics.space6 : 0
                anchors.verticalCenter: root.compact ? undefined : parent.verticalCenter
                anchors.top: root.compact ? parent.top : undefined
                anchors.topMargin: Metrics.space4
                visible: row.count > 0
                count: root.compact ? 0 : row.count
            }
        }

        background: Rectangle {
            radius: Metrics.radiusControl
            color: row.hovered && !row.isCurrent ? Theme.hover : "transparent"

            Behavior on color {
                Tint {}
            }

            FocusRing {
                target: row
            }
        }
    }

    // The list and its selection move together when the scope changes.
    Item {
        id: sheet

        width: parent.width
        height: column.height

        Behavior on x {
            enabled: !root._jump

            FlowSpring {}
        }

        StretchIndicator {
            id: indicator

            anchors.fill: parent
            vertical: true
            target: root._marked
            color: Theme.selected
            radius: Metrics.radiusControl
        }

        Column {
            id: column

            width: parent.width

            Row {
                visible: root._scopeEntry !== null && root._needle === ""
                text: root._scopeEntry ? root._scopeEntry.text ?? "" : ""
                iconName: "back"
                heading: true
                onClicked: root.leave()

                Accessible.name: qsTr("Back")
            }

            Repeater {
                model: root._entries

                delegate: Column {
                    id: entry

                    required property var modelData
                    readonly property bool isDivider: modelData.divider === true
                    readonly property bool isDrill: root._isDrill(modelData)
                    readonly property bool isCategory: modelData.children !== undefined && !isDrill
                    readonly property bool open: root.compact || root._needle !== "" || root.collapsed.indexOf(modelData.text) < 0
                    readonly property bool holdsCurrent: (isCategory || isDrill) && root._holds(modelData, root.current)
                    readonly property bool isCurrent: !isCategory && modelData.id !== undefined && modelData.id === root.current
                    property Item currentPage: null
                    // The item that shows the selection: the page, the header of a closed category, or
                    // the row of a drill parent.
                    readonly property Item mark: holdsCurrent ? (isCategory && open && currentPage ? currentPage : header) : isCurrent ? header : null

                    width: column.width
                    visible: isDivider ? root._needle === "" : isCategory ? modelData.children.some(page => root._matches(page.text)) : root._matches(modelData.text)
                    onMarkChanged: if (mark)
                        root._marked = mark
                    // The list puts its rows in position after the selection changes. The selection
                    // must then go to the row immediately.
                    onYChanged: if (mark)
                        indicator.reposition()

                    // A line between two groups of entries.
                    Item {
                        width: parent.width
                        height: Metrics.space12
                        visible: entry.isDivider

                        Rectangle {
                            x: Metrics.padRow
                            width: parent.width - 2 * Metrics.padRow
                            height: Metrics.lineWidth
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.line
                        }
                    }

                    Row {
                        id: header

                        // The compact list shows only pages, so the header of a category goes away.
                        visible: !entry.isDivider && !(root.compact && entry.isCategory)
                        text: entry.modelData.text ?? ""
                        count: entry.modelData.count ?? 0
                        iconName: entry.modelData.icon ?? ""
                        isCategory: entry.isCategory
                        isDrill: entry.isDrill
                        expanded: entry.open
                        isCurrent: entry.isCurrent || (entry.holdsCurrent && (entry.isDrill || !entry.open))
                        onClicked: {
                            if (entry.isCategory) {
                                root.toggle(entry.modelData.text);
                                return;
                            }
                            if (entry.isDrill)
                                root.enter(root._key(entry.modelData));
                            if (entry.modelData.id !== undefined)
                                root.picked(entry.modelData.id);
                        }
                    }

                    Item {
                        id: body

                        // This value animates, and `height` reads it. `height` cannot be below zero
                        // when the spring overshoots.
                        property real extent: entry.open ? pages.height : 0

                        width: parent.width
                        height: Math.max(0, extent)
                        visible: entry.isCategory && height > 0
                        clip: true
                        opacity: entry.open ? 1 : 0
                        // The rows below move with this item, and the selection must move with them.
                        onHeightChanged: indicator.reposition()

                        Behavior on extent {
                            enabled: root._ready

                            FlowSpring {
                                epsilon: 0.05
                            }
                        }
                        Behavior on opacity {
                            enabled: root._ready

                            Fade {}
                        }

                        Column {
                            id: pages

                            width: parent.width

                            Repeater {
                                model: entry.isCategory ? entry.modelData.children : []

                                delegate: Row {
                                    id: page

                                    required property var modelData

                                    text: modelData.text
                                    iconName: modelData.icon ?? ""
                                    count: modelData.count ?? 0
                                    depth: 1
                                    visible: root._matches(modelData.text)
                                    isCurrent: modelData.id === root.current
                                    onClicked: root.picked(modelData.id)
                                    onIsCurrentChanged: if (isCurrent)
                                        entry.currentPage = page
                                    Component.onCompleted: if (isCurrent)
                                        entry.currentPage = page
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
