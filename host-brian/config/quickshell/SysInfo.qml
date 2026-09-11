import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth: mainRow.implicitWidth + 8
    implicitHeight: Appearance.barHeight

    property string cpuTemp: ""
    property string gpuEdge: ""
    property string gpuJunction: ""
    property string gpuMem: ""
    property string fanPct: ""
    property int vramPct: -1

    function tempColor(temp) {
        if (temp == "" || temp == "?") return "#505050"
        var n = parseInt(temp)
        if (n >= 85) return "#cc6666"
        if (n >= 70) return "#c4a000"
        return "#d0d0d0"
    }

    function updateData(obj) {
        // sysinfo emits one JSON line; null = sensor unavailable
        cpuTemp = obj.cpu === null ? "?" : String(obj.cpu)
        gpuEdge = obj.edge === null ? "?" : String(obj.edge)
        gpuJunction = obj.junc === null ? "?" : String(obj.junc)
        gpuMem = obj.mem === null ? "?" : String(obj.mem)
        fanPct = obj.fan === null ? "?" : String(obj.fan)
        if (obj.vram === null || obj.vram_total === null || obj.vram_total === 0)
            vramPct = -1
        else
            vramPct = Math.round((obj.vram / obj.vram_total) * 100)
    }

    component BarText: Text {
        font.family: Appearance.barFontFamily
        font.pixelSize: Appearance.barFontSize
    }

    component Separator: BarText {
        text: " 󰇙 "
        color: "#505050"
    }

    Row {
        id: mainRow
        anchors.centerIn: parent
        spacing: 2

        // CPU temp
        BarText {
            text: " " + root.cpuTemp + "°"
            color: root.tempColor(root.cpuTemp)
        }

        Separator {}

        // GPU temps
        BarText {
            text: "󰾲 E:" + root.gpuEdge + "°"
            color: root.tempColor(root.gpuEdge)
        }

        BarText {
            text: "J:" + root.gpuJunction + "°"
            color: root.tempColor(root.gpuJunction)
        }

        BarText {
            text: "M:" + root.gpuMem + "°"
            color: root.tempColor(root.gpuMem)
        }

        Separator {}

        // Fan
        BarText {
            text: " " + root.fanPct + "%"
            color: root.fanPct !== "" && root.fanPct !== "?" ? "#909090" : "#505050"
        }

        Separator {}

        // VRAM progress bar
        Item {
            width: 60
            height: Appearance.barHeight / 2

            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: 5
                color: "#202020"
            }

            Rectangle {
                height: parent.height - 4
                width: root.vramPct < 0 ? 0 : (root.vramPct / 100) * (parent.width - 4)
                radius: 2
                color: {
                    if (root.vramPct < 0) return "#505050"
                    if (root.vramPct >= 90) return "#cc6666"
                    if (root.vramPct >= 70) return "#c4a000"
                    return "#66aaff"
                }
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 2
            }

            BarText {
                text: root.vramPct < 0 ? "?" : root.vramPct + "%"
                anchors.centerIn: parent
                color: root.vramPct < 0 ? "#505050" : "#d0d0d0"
                font.pixelSize: Appearance.barFontSize - 2
            }
        }
    }

    Process {
        id: sysinfoProc
        command: ["sysinfo"]
        stdout: SplitParser {
            onRead: data => {
                if (data.length === 0)
                    return
                var obj
                try { obj = JSON.parse(data) } catch (err) { return }
                root.updateData(obj)
            }
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: sysinfoProc.running = true
    }
}
