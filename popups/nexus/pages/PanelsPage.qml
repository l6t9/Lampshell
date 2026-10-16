import QtQuick
import qs.theme
import qs.services
import qs.popups.settings
import qs.popups.nexus
import qs.popups.nexus.common

PageBase {
    id: root

    title: "Panels"
    description: "Bars, tray and status items"

    SettingsGroup {
        title: "Top bar"
        description: "Always spans the full width of each monitor."

        InfoRow {
            label: "Height"
            value: Math.round(Layout.topBarHeight) + " px"
        }
        InfoRow {
            label: "Hidden on fullscreen"
            value: "yes"
        }
        ToggleRow {
            icon: "music_note"
            label: "Show Now Playing widget"
            description: "Shows the Now Playing status and allows to control playback directly from your bar."

            checked: SettingsStore.values.musicPlayerWidgetEnabled
            onToggled: checked => SettingsStore.set("musicPlayerWidgetEnabled", checked)
        }
        SliderRow {
            icon: "fullscreen"
            label: "Scaling"
            suffix: "%"
            value: Math.round(SettingsStore.values.uiScale*100)
            from: 50
            to: 200
            snap: 25
            resetEnabled: true
            reset: 100
            onMoved: value => SettingsStore.set("uiScale", value/100.0)
        }
        InfoRow {
            label: "WARNING : Scaling is experimental and should only be used for development purposes."
            
        }
    }

    SettingsGroup {
        title: "Status"

        InfoRow {
            label: "Workspace slots"
            value: "1 - 10"
        }
        InfoRow {
            label: "Clock"
            value: "centre"
        }
        InfoRow {
            label: "Tray and status"
            value: "right"
        }
    }

    SectionHeader {
        text: "Not yet configurable"
        description: "Panel layout is currently fixed in bar/TopBar.qml. Making the entries reorderable means describing them in data and instantiating from that, the way Caelestia's Bar.qml does with Config.bar.entries."
    }
}
