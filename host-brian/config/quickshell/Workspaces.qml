// Workspaces on one output. The bar's focus line already marks the focused
// screen, so this stays quiet: hidden workspaces are faint, the one visible on
// this output is bright with a short underline (accent on the focused output).
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3

RowLayout {
    id: root

    property var screen
    property string outputName: screen ? screen.name : ""
    property int itemHeight: Appearance.barHeight
    property int minItemWidth: Appearance.workspaceMinWidth
    property int horizontalPadding: Appearance.workspaceHorizontalPadding
    property int fontPixelSize: Appearance.barFontSize

    function isOnOutput(workspace) {
        var workspaceOutput = workspace.lastIpcObject.output
            || (workspace.monitor ? workspace.monitor.name : "")
        return outputName !== "" && workspaceOutput === outputName
    }

    spacing: 2

    Repeater {
        model: I3.workspaces

        Item {
            id: workspace

            required property var modelData

            readonly property bool focused: I3.focusedWorkspace === modelData
            readonly property bool visibleOnOutput: modelData.active
            readonly property bool urgent: modelData.urgent
            readonly property bool onOutput: root.isOnOutput(modelData)
            readonly property bool hovered: mouseArea.containsMouse

            readonly property color markColor: urgent ? Appearance.dangerColor
                : focused ? Appearance.focusLineColor
                : Appearance.textDim

            visible: onOutput
            implicitWidth: onOutput ? Math.max(root.minItemWidth, label.implicitWidth + root.horizontalPadding * 2) : 0
            implicitHeight: onOutput ? root.itemHeight : 0

            Rectangle {
                anchors {
                    fill: parent
                    topMargin: 4
                    bottomMargin: 4
                }
                radius: 6
                color: workspace.hovered ? Appearance.hoverBackground : "transparent"

                Behavior on color { ColorAnimation { duration: Appearance.hoverDuration } }
            }

            Text {
                id: label

                anchors.centerIn: parent
                text: workspace.modelData.name
                color: workspace.urgent ? Appearance.dangerColor
                    : workspace.visibleOnOutput ? Appearance.textBright
                    : workspace.hovered ? Appearance.textDim
                    : Appearance.textFaint
                font.family: Appearance.barFontFamily
                font.pixelSize: root.fontPixelSize

                Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.OutCubic } }
            }

            // Underline: grows in when the workspace becomes visible here.
            Rectangle {
                readonly property bool shown: workspace.visibleOnOutput || workspace.urgent

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: label.bottom
                anchors.topMargin: 1
                width: shown ? Math.max(10, label.implicitWidth) : 0
                height: 2
                radius: 1
                color: workspace.markColor
                opacity: shown ? 1 : 0

                Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 140 } }
                Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: workspace.modelData.activate()
            }
        }
    }
}
