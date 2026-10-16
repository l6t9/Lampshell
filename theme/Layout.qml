pragma Singleton

import QtQuick
import qs.services

QtObject {
    property int topBarHeight: s(50)
    property int sideBarWidth: 10
    property int rightBarWidth: 10
    property int bottomBarHeight: s(10)

    property int cornerRadius: 20

    property int panelRadius: 28

    // Connected-card metrics (Metrolist-KMP settings groups): a run of rows shares one card, separated by a small gap.
    property int connectedOuterRadius: 20
    property int connectedInnerRadius: 5
    property int connectedSpacing: 4
    property int rowMinHeight: 72

    property real uiScale: SettingsStore.values.uiScale

    function s(n) { return Math.round(n * uiScale) }
    function ts(n) { return Math.max(14, Math.round(n * uiScale)) }

    property string fontSans: "Google Sans"
    property string fontIcons: "Material Symbols Rounded"

    property string targetMonitor: ""
}
