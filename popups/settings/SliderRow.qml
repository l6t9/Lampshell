import QtQuick
import qs.theme

Item {
    id: root

    property string icon: ""
    property string label: ""
    property string suffix: "%"
    property string valueLabel: ""
    property real value: 0
    property real from: 0
    property real to: 100
    property real snap: -1
    property bool resetEnabled: false
    property real reset: 0
    signal moved(real value)

    property bool dragging: false
    property bool enabled: true

    opacity: enabled ? 1 : 0.4
    Behavior on opacity {
        NumberAnimation {
            duration: 120
        }
    }

    property bool isFirst: true
    property bool isLast: true

    function setGroupShape(first, last) {
        isFirst = first;
        isLast = last;
    }
    function snapf(value, snap) {
        if (snap <= 0) {
            return value
        }
        let new_val = value - root.from
        return Math.round(new_val/snap)*snap+root.from
    }
    readonly property real outerRadius: Layout.connectedOuterRadius
    readonly property real innerRadius: Layout.connectedInnerRadius

    Rectangle {
        id: groupSurface
        anchors.fill: parent
        z: -1
        color: Theme.surface_container
        topLeftRadius: root.isFirst ? root.outerRadius : root.innerRadius
        topRightRadius: root.isFirst ? root.outerRadius : root.innerRadius
        bottomLeftRadius: root.isLast ? root.outerRadius : root.innerRadius
        bottomRightRadius: root.isLast ? root.outerRadius : root.innerRadius
    }

    implicitHeight: Layout.rowMinHeight
    width: parent ? parent.width : 0

    opacity: enabled ? 1.0 : 0.38

    Row {
        id: row
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Text {
            id: iconText
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            text: root.icon
            color: Theme.on_surface_variant
            font {
                family: Layout.fontIcons
                pixelSize: 19
            }
        }

        Text {
            id: labelText
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(Math.max(92, implicitWidth), 150)
            elide: Text.ElideRight
            text: root.label
            color: Theme.on_surface
            font {
                family: Layout.fontSans
                pixelSize: 16
            }
        }

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(0, row.width - iconText.width - labelText.width - valueText.width - valueBadge.width - row.spacing * 4)
            height: 8
            radius: 4
            color: Theme.surface_container_highest

            Rectangle {
                width: track.width * ((root.snapf(root.value,root.snap) - root.from) / Math.max(1, root.to - root.from))
                height: parent.height
                radius: parent.radius
                color: Theme.primary
            }
            
            Rectangle {
                x: Math.max(0, Math.min(track.width - width, track.width * ((root.snapf(root.value,root.snap) - root.from) / Math.max(1, root.to - root.from)) - width / 2))
                y: (track.height - height) / 2
                width: 20
                height: 20
                radius: 10
                color: Theme.primary
                border.width: 2
                border.color: Theme.surface_container_low

                scale: dragMouse.pressed ? 1.15 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 90
                    }
                }
            }

            MouseArea {
                id: dragMouse
                anchors.fill: parent
                anchors.margins: -10
                enabled: root.enabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onPressed: function(event) {
                    root.dragging = true;
                    track.applyAt(event.x);
                }
                onPositionChanged: function(event) {
                    if (root.dragging)
                        track.applyAt(event.x);
                }
                onReleased: {
                    root.dragging = false;
                }

                onExited: root.dragging = false
            }

            function applyAt(px) {
                const ratio = Math.max(0, Math.min(1, px / Math.max(1, track.width)));
                const v = root.from + ratio * (root.to - root.from);

                root.dragging = true;
                root.moved(root.snapf(v,root.snap));
            }
        }

        Text {
            id: valueText
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            horizontalAlignment: Text.AlignRight
            visible: root.valueLabel.length === 0
            text: Math.round(root.value) + root.suffix
            color: Theme.primary
            font {
                family: Layout.fontSans
                pixelSize: 14
                weight: Font.Medium
            }
        }

        Rectangle {
            id: valueBadge
            anchors.verticalCenter: parent.verticalCenter
            width: 62
            height: 26
            radius: 8
            visible: root.valueLabel.length > 0
            color: Theme.secondary_container

            Text {
                anchors.centerIn: parent
                text: root.valueLabel
                color: Theme.on_secondary_container
                font {
                    family: "Google Sans"
                    pixelSize: 11
                    weight: Font.Medium
                }
            }
        }
        Rectangle {
            id: resetButton
            property bool hovered
            anchors.verticalCenter: parent.verticalCenter
            height:Layout.s(32)
            width:Layout.s(32)
            radius: width/2
            visible: root.resetEnabled && root.reset !== root.value
            color: hovered ? Theme.background : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
            Text {
                anchors.centerIn: parent
                text: "refresh"
                color: Theme.on_primary_container
                font {
                    family: Layout.fontIcons
                    pixelSize: Layout.s(24)
                    weight: Font.Medium
                }
            }

            MouseArea {
                id: resetButtonArea
                anchors.fill: parent
                //anchors.margins: -10
                enabled: root.enabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onPressed: function(event) {
                    root.moved(reset)
                }
                onEntered: {resetButton.hovered = true}
                onExited: {resetButton.hovered = false}
                
            }

        }
    }
}
