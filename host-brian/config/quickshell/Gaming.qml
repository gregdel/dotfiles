import QtQuick
import Quickshell
import Quickshell.Io

Item {
    implicitWidth: gamingLabel.implicitWidth + 20
    implicitHeight: 30

    Text {
        id: gamingLabel
        anchors.centerIn: parent
        color: "#d0d0d0"
        font.family: "monospace"
        font.pixelSize: 14
    }

    Process {
        id: ps4Controller
        command: ["ps4-controller"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => gamingLabel.text = data
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: ps4Controller.running = true
    }
}
