import QtQuick
import qs.services
import qs.theme

Rectangle {
    id: root

    enum ScrollType {
        Infinite = 0, // the text scrolls infinitely to the left and loops around when it goes too far
        BackAndForth = 1, // the text scrolls left then right
        Auto = 2 // BackAndForth if the text's size is less than twice the visible area's size, Infinite otherwise
    }

    // pauses the animation
    property bool paused: false
    // when false, stops all scrolling and elides the text instead
    property bool scrolling_enabled: true
    // animation velocity
    property int scroll_speed: 25
    // separator used in the infinite scrolling mode
    property string scroll_separator: "               "
    // in milliseconds
    property int pause_duration: 2000
    // the Text wrapped inside of the ScrollingText
    property Text innerText: iText
    // the type of scrolling ScrollingText should apply to the text
    property int scrollType: ScrollingText.ScrollType.Infinite
    property string _oldText: ""
    property bool _scrolling_enabled: scrolling_enabled && !GameMode.enabled

    // sets all needed properties
    function refresh(reset = true) {
        // current data is insufficient to control the scrolling correctly so we return
        if (iText.width === 0 || Math.max(root.width, root.implicitWidth) === 0)
            return ;

        // we determine which animation should play
        let currentAnimation = null;
        if (scrollType === ScrollingText.ScrollType.Auto) {
            // auto animation mode handling
            if (iText.contentWidth / 2 > Math.max(root.width, root.implicitWidth)) {
                currentAnimation = textAnimInfinite;
                textAnimBackAndForth.stop();
            } else {
                currentAnimation = textAnimBackAndForth;
                textAnimInfinite.stop();
            }
        } else {
            // non auto animations
            currentAnimation = scrollType === ScrollingText.ScrollType.BackAndForth ? textAnimBackAndForth : textAnimInfinite;
        }
        if (reset)
            currentAnimation.complete();

        if (iText.width <= Math.max(root.width, root.implicitWidth) || !root._scrolling_enabled) {
            // if you need justified text alignment do it yourself

            currentAnimation.stop();
            if (!root._scrolling_enabled) {
                iText.x = 0;
            } else {
                if (iText.horizontalAlignment === Text.AlignLeft)
                    iText.x = 0;
                else if (iText.horizontalAlignment === Text.AlignHCenter)
                    iText.x = Math.round((Math.max(root.width, root.implicitWidth) / 2) - (iText.contentWidth / 2));
                else if (iText.horizontalAlignment === Text.AlignRight)
                    iText.x = Math.round((Math.max(root.width, root.implicitWidth)) - (iText.contentWidth));
            }
        } else if (root.paused) {
            currentAnimation.pause();
        } else if (!currentAnimation.running) {
            iText.x = 0;
            currentAnimation.start();
        } else {
            currentAnimation.resume();
        }
    }

    Component.onCompleted: {
        refresh(true);
    }
    clip: true
    height: iText.contentHeight
    color: "transparent"
    on_Scrolling_enabledChanged: {
        root.refresh(true);
    }
    onPausedChanged: root.refresh(false)

    // this component just follows the real text and only displays when the scrolling mode is set to infinite
    Text {
        id: secondText

        visible: textAnimInfinite.running
        height: contentHeight
        width: contentWidth
        text: root.scroll_separator + iText.text
        x: iText.x + iText.contentWidth
        font: iText.font
        color: iText.color

        anchors {
            verticalCenter: parent.verticalCenter
        }

    }

    Text {
        id: iText

        height: contentHeight
        width: _scrolling_enabled ? contentWidth : root.width
        elide: _scrolling_enabled ? Text.ElideNone : Text.ElideRight
        onWidthChanged: root.refresh(true) // kinda hacky but works
        onTextChanged: {
            if (iText.text !== root._oldText) {
                root.refresh(true);
                root._oldText = iText.text;
            }
        }

        anchors {
            verticalCenter: parent.verticalCenter
        }

        SequentialAnimation on x {
            id: textAnimInfinite

            running: false
            loops: Animation.Infinite

            PauseAnimation {
                duration: root.pause_duration
            }

            SmoothedAnimation {
                to: -secondText.contentWidth
                velocity: root.scroll_speed
                maximumEasingTime: 100
            }

            PropertyAction {
                value: 0
            }

        }

        SequentialAnimation on x {
            id: textAnimBackAndForth

            running: false
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
