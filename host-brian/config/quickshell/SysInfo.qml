import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth: tempRow.implicitWidth + 8
    implicitHeight: 30

    property string cpuTemp: ""
    property string gpuTemp: ""

    function tempColor(temp) {
        if (temp == "" || temp == "?") return "#505050"
        var n = parseInt(temp)
        if (n >= 85) return "#cc6666"
        if (n >= 70) return "#c4a000"
        return "#d0d0d0"
    }

    function updateTemps(data) {
        var matches = data.match(/([0-9?]+)°/g)
        if (!matches || matches.length < 2) return
        cpuTemp = matches[0].replace("°", "")
        gpuTemp = matches[1].replace("°", "")
    }

    Row {
        id: tempRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: [
                { icon: "", temp: root.cpuTemp, label: "CPU" },
                { icon: "󰾲", temp: root.gpuTemp, label: "GPU" }
            ]

            Item {
                required property var modelData

                visible: modelData.temp !== ""
                implicitWidth: tempText.implicitWidth + 18
                implicitHeight: 30

                Rectangle {
                    anchors {
                        fill: parent
                        topMargin: 4
                        bottomMargin: 4
                        leftMargin: 3
                        rightMargin: 3
                    }
                    radius: 6
                    color: "transparent"
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        text: modelData.icon
                        color: modelData.temp == "?" ? "#505050" : "#909090"
                        font.family: "monospace"
                        font.pixelSize: 14
                    }

                    Text {
                        id: tempText
                        text: modelData.temp + "°"
                        color: root.tempColor(modelData.temp)
                        font.family: "monospace"
                        font.pixelSize: 14
                    }
                }
            }
        }
    }

    Process {
        id: barTemp
        command: ["bar-temp"]
        stdout: SplitParser {
            onRead: data => {
                if (data.length > 0)
                    root.updateTemps(data)
            }
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: barTemp.running = true
    }
}
