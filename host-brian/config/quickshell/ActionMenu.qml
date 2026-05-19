import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    property var barWindow

    implicitWidth: 30
    implicitHeight: 30

    Process {
        id: cmdRunner
        command: ["sh", "-c", "true"]
    }

    function runCmd(cmd) {
        cmdRunner.command = ["sh", "-c", cmd]
        cmdRunner.running = true
    }

    Text {
        anchors.centerIn: parent
        text: ""
        color: btnMouse.containsMouse ? "#c4a000" : "#d0d0d0"
        font.family: "monospace"
        font.pixelSize: 14
    }

    MouseArea {
        id: btnMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: actionPopup.visible = !actionPopup.visible
    }

    PopupWindow {
        id: actionPopup
        visible: false

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom

        implicitWidth: 220
        implicitHeight: actionCol.implicitHeight + 16
        color: "#202020"

        HoverHandler {
            onHoveredChanged: if (!hovered) actionPopup.visible = false
        }

        Column {
            id: actionCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 8
            }
            spacing: 2

            MenuButton {
                width: parent.width
                iconProc: "sway-monitor HDMI-A-2"
                iconInterval: 5000
                label: "Toggle monitor output"
                onActivated: {
                    actionPopup.visible = false
                    root.runCmd("sway-monitor HDMI-A-2 toggle")
                }
            }

            MenuButton {
                width: parent.width
                iconProc: "sway-monitor DP-1"
                iconInterval: 5000
                label: "Toggle TV output"
                onActivated: {
                    actionPopup.visible = false
                    root.runCmd("sway-monitor DP-1 toggle")
                }
            }

            MenuButton {
                width: parent.width
                iconProc: "swayidle-toggle icon"
                iconInterval: 10000
                label: "Toggle auto sleep"
                onActivated: {
                    actionPopup.visible = false
                    root.runCmd("swayidle-toggle toggle")
                }
            }

            MenuButton {
                width: parent.width
                staticIcon: "󰻅"
                label: "TV ON/OFF"
                onActivated: {
                    actionPopup.visible = false
                    root.runCmd("tv-remote")
                }
            }

            MenuButton {
                width: parent.width
                staticIcon: ""
                label: "Launch Steam"
                onActivated: {
                    actionPopup.visible = false
                    root.runCmd("steam")
                }
            }
        }
    }
}
