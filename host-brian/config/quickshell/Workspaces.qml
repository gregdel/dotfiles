import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3

RowLayout {
    spacing: 4

    Repeater {
        model: I3.workspaces

        Rectangle {
            required property var modelData
            required property int index

            property bool focused: I3.focusedWorkspace === modelData

            implicitWidth: label.implicitWidth + 16
            implicitHeight: 30
            color: "transparent"

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 2
                color: focused ? "#c4a000"
                    : (parent.containsMouse ? "#505050" : "transparent")
            }

            Text {
                id: label
                anchors.centerIn: parent
                text: modelData.name
                color: focused ? "#d0d0d0" : "#808080"
                font.family: "monospace"
                font.pixelSize: 14
            }

            property bool containsMouse: mouseArea.containsMouse

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: I3.dispatch("workspace " + modelData.name)
            }
        }
    }
}
