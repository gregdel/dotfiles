import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3

RowLayout {
    id: root

    property var screen
    property var monitor: screen ? I3.monitorFor(screen) : null
    property string outputName: screen ? screen.name : ""
    property int pillHeight: 22
    property int minPillWidth: 28
    property int horizontalPadding: 10

    function isActiveOnOutput(workspace) {
        return workspace.active
    }

    function isOnOutput(workspace) {
        var workspaceOutput = workspace.lastIpcObject.output
            || (workspace.monitor ? workspace.monitor.name : "")
        return outputName !== "" && workspaceOutput === outputName
    }

    spacing: 5

    Repeater {
        model: I3.workspaces

        Rectangle {
            required property var modelData
            required property int index

            property bool focused: I3.focusedWorkspace === modelData
            property bool activeOnOutput: root.isActiveOnOutput(modelData)
            property bool urgent: modelData.urgent
            property bool onOutput: root.isOnOutput(modelData)
            property bool hovered: mouseArea.containsMouse
            property color normalBackground: hovered ? "#1b1b1b" : "transparent"
            property color activeBackground: focused ? "#2a2514" : "#1f1f1f"
            property color urgentBackground: hovered ? "#4a2020" : "#361818"
            property color normalBorder: hovered ? "#3a3a3a" : "transparent"
            property color activeBorder: focused ? "#c4a000" : "#5f5525"
            property color urgentBorder: "#cc6666"

            visible: onOutput
            implicitWidth: onOutput ? Math.max(root.minPillWidth, label.implicitWidth + root.horizontalPadding * 2) : 0
            implicitHeight: onOutput ? 30 : 0
            color: "transparent"

            Rectangle {
                id: pill

                anchors.centerIn: parent
                width: parent.implicitWidth
                height: root.pillHeight
                radius: 9
                color: urgent ? parent.urgentBackground
                    : activeOnOutput ? parent.activeBackground
                    : parent.normalBackground
                border.width: urgent || activeOnOutput || parent.hovered ? 1 : 0
                border.color: urgent ? parent.urgentBorder
                    : activeOnOutput ? parent.activeBorder
                    : parent.normalBorder

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    id: label

                    anchors.centerIn: parent
                    text: modelData.name
                    color: urgent ? "#f0d0d0"
                        : focused ? "#f2d36b"
                        : activeOnOutput ? "#d0d0d0"
                        : parent.parent.hovered ? "#b8b8b8" : "#808080"
                    font.family: "monospace"
                    font.pixelSize: 14
                    font.bold: focused || urgent

                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: I3.dispatch("workspace " + modelData.name)
            }
        }
    }
}
