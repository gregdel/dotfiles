import QtQuick
import Quickshell
import Quickshell.Io

Item {
    implicitWidth: gamingLabel.implicitWidth + 20
    implicitHeight: 30

    property bool disconnected: gamingLabel.text == "󰖻"

    Text {
        id: gamingLabel
        anchors.centerIn: parent
        color: parent.disconnected ? "#505050" : "#d0d0d0"
        font.family: "monospace"
        font.pixelSize: 14
        text: ""
    }

    Process {
        id: ps4Controller
        command: ["ps4-controller"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (data.length > 0)
                    gamingLabel.text = data
            }
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
