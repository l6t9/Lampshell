import QtQuick
import qs.theme

Item {
    id: root

    property string label: ""
    property string value: ""

    property bool isFirst: true
    property bool isLast: true

    function setGroupShape(first, last) {
        isFirst = first;
        isLast = last;
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

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: value === "" ? parent.width - 16 : (Math.max(0, parent.width * 0.4 - 16))
        text: root.label
        elide: Text.ElideRight
        color: Theme.on_surface
        font {
            family: Layout.fontSans
            pixelSize: 16
        }
    }

    Text {
        visible: value !== ""
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.4
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
        text: root.value
        color: Theme.primary
        font {
            family: Layout.fontSans
            pixelSize: 14
            weight: Font.Medium
        }
    }
}
