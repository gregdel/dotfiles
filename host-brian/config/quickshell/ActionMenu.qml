import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3

BarSection {
    id: root
    property var monitorValues: I3.monitors.values

    clickable: true

    CommandRunner {
        id: runner
        name: "Action"
    }

    StatText {
        text: ""
        font.pixelSize: Appearance.barFontSize
    }

    popup: BarPopup {
        id: menu
        cardWidth: 220
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

                width: parent.width
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
                    color: rowMouse.containsMouse ? Appearance.hoverBackground : "transparent"
                    Behavior on color { ColorAnimation { duration: Appearance.hoverDuration } }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        spacing: 8

                        Text {
                            text: outputRow.visibleOutput ? modelData.onIcon : modelData.offIcon
                            color: outputRow.visibleOutput ? Appearance.textColor : Appearance.inactiveColor
                            font.family: Appearance.fontFamily
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            Layout.preferredWidth: 22
                        }

                        Text {
                            text: modelData.label
                            color: outputRow.visibleOutput ? Appearance.textColor : Appearance.textMuted
                            font.family: Appearance.fontFamily
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
                        menu.close()
                        // Monitors are refreshed by the output event handler in shell.qml.
                        if (outputRow.visibleOutput) {
                            I3.dispatch("output " + modelData.outputName + " disable")
                        } else {
                            I3.dispatch("output " + modelData.outputName + " enable, output " + modelData.outputName + " power on")
                        }
                    }
                }
            }
        }

        MenuButton {
            width: parent.width
            iconCommand: ["swayidle-toggle", "icon"]
            iconInterval: 10000
            polling: menu.visible
            label: "Toggle auto sleep"
            onActivated: {
                menu.close()
                runner.run(["swayidle-toggle", "toggle"])
            }
        }

        MenuButton {
            width: parent.width
            staticIcon: "󰻅"
            label: "TV ON/OFF"
            onActivated: {
                menu.close()
                runner.run(["tv-remote"])
            }
        }

        MenuButton {
            width: parent.width
            staticIcon: ""
            label: "Launch Steam"
            onActivated: {
                menu.close()
                Quickshell.execDetached(["gamescope-steam"])
            }
        }
    }
}
