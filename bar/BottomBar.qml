import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "widgets"
import qs.theme
import qs.services

Variants {
    id: root
    model: Quickshell.screens

    property var statusPillHandler: function() {}

    delegate: PanelWindow {
        id: bottomBarWindow

        required property var modelData
        screen: modelData

        readonly property bool active: Layout.barPosition === "bottom"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-bottombar"

        readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
        readonly property bool fullscreen: FullscreenState.isFullscreen(monitor)

        anchors {
            left: true
            right: true
            bottom: true
        }

        color: "transparent"

        implicitHeight: fullscreen ? 0 : Layout.bottomBarHeight
        WlrLayershell.exclusiveZone: fullscreen ? 0 : Layout.bottomBarHeight

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Loader {
            anchors.fill: parent
            active: bottomBarWindow.active
            visible: !bottomBarWindow.fullscreen

            sourceComponent: Component {
                BarContent {
                    windowHandle: bottomBarWindow
                    statusPillHandler: root.statusPillHandler
                    showMpris: true
                }
            }
        }
    }
}
