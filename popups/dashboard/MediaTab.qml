import QtQuick
import qs.theme
import qs.services
import qs.utilities


Item {
    id: root

    implicitWidth: Layout.s(828)
    implicitHeight: Layout.s(470)

    readonly property var player: Players.active

    function fmt(seconds) {
        if (!seconds || seconds <= 0 || isNaN(seconds))
            return "0:00";
        const s = Math.floor(seconds % 60);
        const m = Math.floor((seconds / 60) % 60);
        const h = Math.floor(seconds / 3600);
        const mm = h > 0 ? String(m).padStart(2, "0") : String(m);
        return (h > 0 ? h + ":" : "") + mm + ":" + String(s).padStart(2, "0");
    }

    Column {
        anchors.centerIn: parent
        visible: !root.player
        spacing: Layout.s(12)

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Layout.s(96)
            height: Layout.s(96)
            radius: width / 2
            color: Theme.primary_container

            Text {
                anchors.centerIn: parent
                text: "queue_music"
                color: Theme.on_primary_container
                font {
                    family: Layout.fontIcons
                    pixelSize: Layout.s(44)
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Nothing playing"
            color: Theme.on_surface
            font {
                family: Layout.fontSans
                pixelSize: Layout.s(18)
                weight: Font.Medium
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Play something for it to show up here!"
            color: Theme.on_surface_variant
            font {
                family: Layout.fontSans
                pixelSize: Layout.s(13)
            }
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: Layout.s(16)
        spacing: Layout.s(28)
        visible: root.player !== null

        ShapeArt {
            id: artFrame

            width: Layout.s(280)
            height: Layout.s(280)
            anchors.verticalCenter: parent.verticalCenter
            source: root.player ? (root.player.trackArtUrl ?? "") : ""
            fallbackColor: Theme.surface_container_high
            fallbackIconSize: Layout.s(64)
            spinning: root.player ? root.player.isPlaying : false
        }

        Column {
            width: parent.width - artFrame.width - parent.spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: Layout.s(10)

            Text {
                width: parent.width
                text: root.player ? (root.player.identity ?? "") : ""
                color: Theme.primary
                elide: Text.ElideRight
                font {
                    family: Layout.fontSans
                    pixelSize: Layout.s(12)
                    weight: Font.Medium
                    letterSpacing: 0.5
                }
            }

            ScrollingText {
                width: parent.width
                paused:false
                innerText.maximumLineCount : GameMode.enabled ? 2 : 1
                innerText.wrapMode : GameMode.enabled ? Text.Wrap : Text.NoWrap
                innerText.text: root.player ? (root.player.trackTitle || "Unknown title") : ""
                innerText.color: Theme.on_surface
                innerText.font {
                    family: Layout.fontSans
                    pixelSize: Layout.s(30)
                    weight: Font.DemiBold
                }
            }

            ScrollingText {
                width: parent.width
                innerText.text: {
                    if (!root.player)
                        return "";
                    const artist = root.player.trackArtist || "";
                    const album = root.player.trackAlbum || "";
                    return album.length > 0 ? artist + " — " + album : artist;
                }
                innerText.color: Theme.on_surface_variant
                innerText.font {
                    family: Layout.fontSans
                    pixelSize: Layout.s(16)
                }
            }

            Item {
                width: parent.width
                height: Layout.s(22)

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: Layout.s(5)
                    radius: height / 2
                    color: Theme.surface_container_highest

                    Rectangle {
                        width: parent.width * (root.player && root.player.length > 0
                            ? Math.max(0, Math.min(1, root.player.position / root.player.length))
                            : 0)
                        height: parent.height
                        radius: height / 2
                        color: Theme.primary

                        Behavior on width {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.Linear
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: Layout.s(16)

                Text {
                    anchors.left: parent.left
                    text: root.player ? root.fmt(root.player.position) : "0:00"
                    color: Theme.on_surface_variant
                    font {
                        family: Layout.fontSans
                        pixelSize: Layout.s(12)
                    }
                }

                Text {
                    anchors.right: parent.right
                    text: root.player ? root.fmt(root.player.length) : "0:00"
                    color: Theme.on_surface_variant
                    font {
                        family: Layout.fontSans
                        pixelSize: Layout.s(12)
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: Layout.s(8)
                spacing: Layout.s(18)

                Repeater {
                    model: [
                        { icon: "skip_previous", action: "previous", size: 44 },
                        { icon: root.player && root.player.isPlaying ? "pause" : "play_arrow", action: "toggle", size: 44 },
                        { icon: "skip_next", action: "next", size: 44 }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        anchors.verticalCenter: parent.verticalCenter
                        width: modelData.size + Layout.s(16)
                        height: width
                        radius: width / 2
                        scale: modelArea.containsPress ? 0.9 : 1.0
                        color: modelData.action === "toggle" ? (modelArea.containsMouse ? Theme.secondary : Theme.primary) : "transparent"
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
                            id: modelArea
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
    }
}