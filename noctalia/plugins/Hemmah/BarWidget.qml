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

    property string hemmahText: ""

    readonly property real contentWidth:  row.implicitWidth + Style.marginM * 2
    readonly property real contentHeight: capsuleHeight

    implicitWidth:  contentWidth
    implicitHeight: contentHeight

    Process {
        id: hemmahProc
        command: ["bash", "-c",
            "~/Links/Hemmah/src/extras/widgets/hemmah-prompt.sh 2>/dev/null || echo ''"]
        stdout: SplitParser {
            onRead: data => root.hemmahText = data.trim()
        }
    }

    Timer {
        interval: 3600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!hemmahProc.running)
                hemmahProc.running = true
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

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Style.marginS

            NText {
                text:        root.hemmahText !== "" ? root.hemmahText : "—"
                color:       Color.mOnSurface
                pointSize:   root.barFontSize
                font.weight: Font.Normal
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked: {
            if (!hemmahProc.running)
                hemmahProc.running = true
        }
    }

    Component.onCompleted: Logger.i("Hemmah", "Widget loaded")
}
