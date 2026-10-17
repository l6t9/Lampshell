import QtQuick
import Quickshell.Services.Mpris
import qs.popups.dashboard
import qs.services
import qs.theme
import qs.utilities

Item {
    id: root

    visible: SettingsStore.values.musicPlayerWidgetEnabled

    implicitWidth: visualPill.implicitWidth
    implicitHeight: visualPill.implicitHeight

    Rectangle {
        id: visualPill

        anchors.centerIn: parent
        implicitWidth: coverImage.width + timeLabel.width + (Players.active ? playerButtons.implicitWidth : Layout.s(10)) + Layout.s(10)
        implicitHeight: timeLabel.height + Layout.s(16)
        radius: height / 2
        color: {
            if (pillMouse.containsMouse)
                return Qt.tint(Theme.surface_container, Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08));
            return Theme.surface_container;
        }
        scale: pillMouse.pressed ? 0.95 : 1

        MouseArea {
            id: pillMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                DashboardState.tab = 1;
                DashboardState.requestToggle();
            }
        }

        ShapeArt {
            id: coverImage

            width: Layout.s(40)
            height: Layout.s(40)
            source: Players.active ? (Players.active.trackArtUrl ?? "") : ""
            fallbackColor: Theme.surface_container_high
            fallbackIconSize: Layout.s(16)
            spinning: Players.active ? Players.active.isPlaying : false

            anchors {
                left: parent.left
                leftMargin: Layout.s(-5)
                verticalCenter: parent.verticalCenter
            }

        }

        ScrollingText {
            id: timeLabel
            running: Players.active?.isPlaying ?? false
            width: Layout.s(200)
            height:Layout.s(24)
            innerText.text: {
                if (!Players.active)
                    return "No player was found.";

                if (Players.activeTitle === "")
                    return "Nothing is playing.";

                return Players.activeTitle;
            }
            innerText.color: Theme.on_surface

            anchors {
                left: coverImage.right
                leftMargin: Layout.s(5)
                verticalCenter: parent.verticalCenter
                
            }
            innerText.font {
                family: "Google Sans"
                pointSize: 14
                weight: Font.Medium
            }

            Behavior on innerText.color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }

            }

        }

        Row {
            id: playerButtons

            spacing: Layout.s(8)
            visible: Players.active

            anchors {
                verticalCenter: parent.verticalCenter
                topMargin: Layout.s(8)
                left: timeLabel.right
                right: parent.right
                leftMargin: Layout.s(5)
            }

            Repeater {
                model: [{
                    "icon": "skip_previous",
                    "action": "previous",
                    "size": 20
                }, {
                    "icon": Players.active && Players.active.isPlaying ? "pause" : "play_arrow",
                    "action": "toggle",
                    "size": 20
                }, {
                    "icon": "skip_next",
                    "action": "next",
                    "size": 20
                }]

                delegate: Rectangle {
                    required property var modelData
                    property bool hovered
                    id:model
                    width: modelData.size + Layout.s(16)
                    height: width
                    radius: width / 2
                    scale: model.hovered ? 1.1 : 1.0
                    color: modelData.action === "toggle" ? (model.hovered ? Theme.secondary : Theme.primary) : "transparent"
                    anchors.verticalCenter: parent.verticalCenter
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
                        color: modelData.action === "toggle" ? (model.hovered ? Theme.on_secondary : Theme.on_primary) : Theme.on_surface
                        id:modelText
                        font {
                            family: Layout.fontIcons
                            pixelSize: Layout.s(modelData.size)
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
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            model.hovered = true
                        }
                        onExited: {
                            model.hovered = false
                        }
                        onClicked: {
                            if (!Players.active)
                                return ;

                            if (modelData.action === "toggle")
                                Players.active.togglePlaying();
                            else if (modelData.action === "next")
                                Players.active.next();
                            else if (modelData.action === "previous")
                                Players.active.previous();
                        }
                    }

                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }

        }

    }

}
