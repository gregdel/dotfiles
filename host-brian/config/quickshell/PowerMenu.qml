import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth: 36
    implicitHeight: Appearance.barHeight

    Process {
        id: actionProc
        stderr: StdioCollector {
            onStreamFinished: {
                const message = text.trim()
                if (message.length > 0)
                    console.warn("Power action failed:", message)
            }
        }
    }

    function runCommand(command) {
        if (actionProc.running)
            return

        actionProc.command = command
        actionProc.running = true
    }

    Text {
        anchors.centerIn: parent
        text: "⏻"
        color: btnMouse.containsMouse ? "#c4a000" : "#d0d0d0"
        font.family: Appearance.barFontFamily
        font.pixelSize: Appearance.barFontSize
    }

    MouseArea {
        id: btnMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: powerPopup.visible = !powerPopup.visible
    }

    PopupWindow {
        id: powerPopup
        visible: false

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom

        implicitWidth: 140
        implicitHeight: powerCol.implicitHeight + 16
        color: "transparent"

        HoverHandler {
            onHoveredChanged: if (!hovered) powerPopup.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: Appearance.popupBackground
            radius: Appearance.popupRadius
            antialiasing: true
            clip: true
            border.width: 1
            border.color: Appearance.popupBorder

            Column {
                id: powerCol
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 8
                }
                spacing: 4

                Repeater {
                    model: [
                        { label: "Suspend",  command: ["systemctl", "suspend"] },
                        { label: "Reboot",   command: ["reboot"] },
                        { label: "Shutdown", command: ["shutdown", "now"] }
                    ]

                    Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 36
                        radius: 6
                        color: itemMouse.containsMouse ? "#282828" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: itemMouse.containsMouse ? "#c4a000" : "#d0d0d0"
                            font.family: "monospace"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: itemMouse
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                powerPopup.visible = false
                                root.runCommand(modelData.command)
                            }
                        }
                    }
                }
            }
        }
    }
}
