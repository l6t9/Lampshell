import QtQuick
import qs.services

Rectangle {
    id: root

    // TODO : support horizontal-aligned text for the dashboard's first tab's player widget

    // pauses the animation when set to false
    property bool running: true
    // when false, stops all scrolling and elides the text instead (for a future setting or game mode maybe)
    property bool scrolling_enabled: true
    property bool _scrolling_enabled: scrolling_enabled && !GameMode.enabled
    // animation velocity
    property int scroll_speed: 20
    // in milliseconds
    property int pause_duration: 1750
    // the Text wrapped inside of the ScrollingText
    property Text innerText: iText

    // resets the animation
    function restart() {
        textAnim.complete();
        iText.x = 0;
    }

    clip: true
    height: iText.contentHeight
    color: "transparent"

    on_Scrolling_enabledChanged: root.restart()

    Text {
        id: iText

        height: contentHeight
        width: _scrolling_enabled ? contentWidth : root.width
        elide: _scrolling_enabled ? Text.ElideNone : Text.ElideRight
        onTextChanged: root.restart()

        anchors {
            verticalCenter: parent.verticalCenter
        }

        SequentialAnimation on x {
            id: textAnim

            running: root._scrolling_enabled
            paused: (iText.contentWidth < root.width) || !root.running
            loops: Animation.Infinite

            PauseAnimation {
                duration: root.pause_duration
            }

            SmoothedAnimation {
                from: 0
                to: root.width - iText.contentWidth
                velocity: root.scroll_speed
                maximumEasingTime: 100
            }

            PauseAnimation {
                duration: root.pause_duration
            }

            SmoothedAnimation {
                from: root.width - iText.contentWidth
                to: 0
                velocity: root.scroll_speed
                maximumEasingTime: 100
            }

        }

    }

}
