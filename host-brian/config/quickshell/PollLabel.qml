// Reusable component: run a shell command on interval, display output as text
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    property int interval: 5000
    property string command: ""
    property int leftPad: 10
    property int rightPad: 10

    implicitWidth: label.implicitWidth + leftPad + rightPad
    implicitHeight: 30

    Text {
        id: label
        anchors.centerIn: parent
        color: "#d0d0d0"
        font.family: "monospace"
        font.pixelSize: 14
    }

    Process {
        id: proc
        // Append echo to ensure SplitParser gets a newline-terminated line
        command: ["sh", "-c", parent.command + "; echo"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => { if (data.length > 0) label.text = data }
        }
    }

    Timer {
        interval: parent.interval
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
