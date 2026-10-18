import QtQuick
import qs.theme
import qs.services
import qs.utilities

Item {
    id: root

    implicitWidth: Layout.s(200)
    implicitHeight: Layout.s(440)

    readonly property var player: Players.active
    readonly property real progress: player && player.length > 0 ? (player.position % player.length) / player.length : 0
    readonly property color accent: Theme.primary

    Timer {
        running: root.player ? root.player.isPlaying : false
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.player)
                root.player.positionChanged();
        }
    }

    Item {
        id: coverWrap

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: Layout.s(132)
        height: width

        ProgressRing {
            id: ring

            anchors.centerIn: parent
            width: coverWrap.width + Layout.s(12) + strokeWidth * 2
            height: width
            value: root.progress
            strokeWidth: Layout.s(5)
            startAngle: -180
            sweepAngle: 180
            fgColor: root.accent
            bgColor: Theme.surface_container_highest
        }

        ShapeArt {
            id: cover

            anchors.centerIn: parent
            width: coverWrap.width
            height: width
            source: root.player ? (root.player.trackArtUrl ?? "") : ""
            fallbackColor: Theme.surface_container_high
            fallbackIconSize: Layout.s(40)
            spinning: root.player ? root.player.isPlaying : false
        }
    }

    Column {
        id: info

        anchors.top: coverWrap.bottom
        anchors.topMargin: Layout.s(16)
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Layout.s(3)

        ScrollingText {
            width: parent.width
            innerText.horizontalAlignment: Text.AlignHCenter
            innerText.text: root.player ? (root.player.trackTitle || "Unknown title") : "No media"
            innerText.color: root.accent
            innerText.font {
                family: Layout.fontSans
                pixelSize: Layout.s(15)
                weight: Font.Medium
            }
        }

        ScrollingText {
            width: parent.width
            innerText.horizontalAlignment: Text.AlignHCenter
            innerText.text: root.player ? (root.player.trackAlbum || "Unknown album") : ""
            innerText.color: Theme.outline
            innerText.font {
                family: Layout.fontSans
                pixelSize: Layout.s(12)
            }
        }

        ScrollingText {
            width: parent.width
            innerText.horizontalAlignment: Text.AlignHCenter
            innerText.text: root.player ? (root.player.trackArtist || "Unknown artist") : ""
            innerText.color: Theme.secondary
            innerText.font {
                family: Layout.fontSans
                pixelSize: Layout.s(12)
            }
        }
    }

    Row {
        id: controls

        anchors.top: info.bottom
        anchors.topMargin: Layout.s(16)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Layout.s(10)

        Repeater {
            model: [
                { icon: "skip_previous", action: "previous", size: 34, enabled: !!root.player && root.player.canGoPrevious },
                { icon: root.player && root.player.isPlaying ? "pause" : "play_arrow", action: "toggle", size: 34, enabled: !!root.player && root.player.canTogglePlaying },
                { icon: "skip_next", action: "next", size: 34, enabled: !!root.player && root.player.canGoNext }
            ]

            delegate: Rectangle {
                required property var modelData
                anchors.verticalCenter: parent.verticalCenter
                width: Layout.s(46)
                height: width
                radius: width / 2
                scale: modelArea.containsPress ? 0.9 : 1.0
                color: modelData.action === "toggle" ? (modelArea.containsMouse ? Theme.secondary : Theme.primary) : "transparent"
                opacity: modelData.enabled ? 1 : 0.4
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }

                }
                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    color: modelData.action === "toggle" ? (modelArea.containsMouse ? Theme.on_secondary : Theme.on_primary) : Theme.on_surface
                    id:modelText
                    renderType: Text.NativeRendering
                    font {
                        family: Layout.fontIcons
                        pixelSize: Layout.s(modelData.size)
                        hintingPreference: Font.PreferNoHinting
                        variableAxes: ({ "FILL": 1.0, "opsz": Layout.s(modelData.size) })
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }

                    }
                }

                MouseArea {
                    anchors.fill: parent
                    id:modelArea
                    enabled: modelData.enabled
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!root.player)
                            return;
                        if (modelData.action === "toggle")
                            root.player.togglePlaying();
                        else if (modelData.action === "next")
                            root.player.next();
                        else if (modelData.action === "previous")
                            root.player.previous();
                    }
                }
            }
        }
    }
}
