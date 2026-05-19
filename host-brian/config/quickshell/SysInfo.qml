import QtQuick
import Quickshell
import Quickshell.Io

Item {
    implicitWidth: sysinfo.implicitWidth + 20
    implicitHeight: 30

    Text {
        id: sysinfo
        anchors.centerIn: parent
        color: "#d0d0d0"
        font.family: "monospace"
        font.pixelSize: 14
        text: " ?° 󰾲 ?°"
    }

    Process {
        id: barTemp
        command: ["bar-temp"]
        stdout: SplitParser {
            onRead: data => sysinfo.text = data
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
