import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import Quickshell.Io

Item {
    id: root
    property var barWindow
    property var monitorValues: I3.monitors.values

    implicitWidth: 30
    implicitHeight: 30

    Process {
        id: cmdRunner
        command: ["sh", "-c", "true"]
    }

    Connections {
        target: I3

        function onRawEvent(event) {
            if (event.type === "output")
                I3.refreshMonitors()
        }
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
        cursorShape: Qt.PointingHandCursor
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
        color: "transparent"

        HoverHandler {
            onHoveredChanged: if (!hovered) actionPopup.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: "#202020"
            radius: 8
            antialiasing: true
            clip: true
            border.width: 1
            border.color: "#303030"

            Column {
                id: actionCol
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 8
                }
                spacing: 2

                Repeater {
                    model: [
                        {
                            "outputName": "HDMI-A-2",
                            "label": "Monitor output",
                            "onIcon": "󰍹",
                            "offIcon": "󰍶"
                        },
                        {
                            "outputName": "DP-1",
                            "label": "TV output",
                            "onIcon": "",
                            "offIcon": "󰍶"
                        }
                    ]

                    Item {
                        id: outputRow

                        required property var modelData

                        width: actionCol.width
                        implicitHeight: 38
                        implicitWidth: 200

                        property var monitor: {
                            root.monitorValues
                            return I3.findMonitorByName(modelData.outputName)
                        }
                        property bool visibleOutput: monitor !== null
                            && monitor.lastIpcObject.active === true
                            && monitor.lastIpcObject.power === true

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: rowMouse.containsMouse ? "#282828" : "transparent"

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: 10
                                    rightMargin: 10
                                }
                                spacing: 8

                                Text {
                                    text: outputRow.visibleOutput ? modelData.onIcon : modelData.offIcon
                                    color: outputRow.visibleOutput ? "#d0d0d0" : "#505050"
                                    font.family: "monospace"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.preferredWidth: 22
                                }

                                Text {
                                    text: modelData.label
                                    color: outputRow.visibleOutput ? "#d0d0d0" : "#808080"
                                    font.family: "monospace"
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                actionPopup.visible = false
                                if (outputRow.visibleOutput) {
                                    I3.dispatch("output " + modelData.outputName + " disable")
                                } else {
                                    I3.dispatch("output " + modelData.outputName + " enable, output " + modelData.outputName + " power on")
                                }
                                I3.refreshMonitors()
                            }
                        }
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
}
