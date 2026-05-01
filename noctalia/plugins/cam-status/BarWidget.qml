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

    // NO-CAM → hide widget entirely
    // IDLE   → hide widget (cam exists but not in use)
    // LIVE   → show red camera icon
    property string camState: "IDLE"

    readonly property bool isLive: camState === "LIVE"

    readonly property real contentWidth:  iconItem.implicitWidth + Style.marginM * 2
    readonly property real contentHeight: capsuleHeight

    implicitWidth:  isLive ? contentWidth : 0
    implicitHeight: contentHeight
    visible: isLive

    Process {
        id: camProc
        command: ["bash", "-c",
            "if ! ls /dev/video* >/dev/null 2>&1; then " +
            "  echo NO-CAM; " +
            "elif lsof /dev/video* 2>/dev/null | grep -q video; then " +
            "  echo LIVE; " +
            "else echo IDLE; fi"]
        stdout: SplitParser {
            onRead: data => root.camState = data.trim()
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!camProc.running)
                camProc.running = true
        }
    }

    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width:  root.contentWidth
        height: root.contentHeight
        color:        Style.capsuleColor
        radius:       Style.radiusL
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        NIcon {
            id: iconItem
            anchors.centerIn: parent
            icon:  "video"
            color: Color.mError
        }
    }

    Component.onCompleted: Logger.i("CamStatus", "Widget loaded")
}
