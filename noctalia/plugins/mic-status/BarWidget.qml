import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property string screenName:    screen?.name ?? ""
    readonly property real   capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
    readonly property real   barFontSize:   Style.getBarFontSizeForScreen(screenName)

    // NO-MIC → hide widget entirely
    // MUTED   → red mic-off icon
    // OK      → normal mic icon
    property string micState: "OK"   // "OK" | "MUTED" | "NO-MIC"

    readonly property bool hasMic:   micState !== "NO-MIC"
    readonly property bool isMuted:  micState === "MUTED"

    readonly property real contentWidth:  iconItem.implicitWidth + Style.marginM * 2
    readonly property real contentHeight: capsuleHeight

    implicitWidth:  hasMic ? contentWidth : 0
    implicitHeight: contentHeight
    visible: hasMic

    Process {
        id: micProc
        command: ["bash", "-c",
            "if ! pactl list sources 2>/dev/null | grep -q 'alsa_input'; then " +
            "  echo NO-MIC; " +
            "elif wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null | grep -q MUTED; then " +
            "  echo MUTED; " +
            "else echo OK; fi"]
        stdout: SplitParser {
            onRead: data => root.micState = data.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!micProc.running)
                micProc.running = true
        }
    }

    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width:  root.contentWidth
        height: root.contentHeight
        color:        mouseArea.containsMouse ? Color.mHover : Style.capsuleColor
        radius:       Style.radiusL
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        NIcon {
            id: iconItem
            anchors.centerIn: parent
            icon:  root.isMuted ? "microphone-off" : "microphone"
            color: root.isMuted ? Color.mError : Color.mOnSurfaceVariant
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        // click to toggle mute
        onClicked: {
            const cmd = ["bash", "-c", "wpctl set-mute @DEFAULT_SOURCE@ toggle"]
            const p = Qt.createQmlObject(
                'import Quickshell.Io; Process { command: ' + JSON.stringify(cmd) + '; running: true }',
                root, "toggleMic"
            )
        }
    }

    Component.onCompleted: Logger.i("MicStatus", "Widget loaded")
}
