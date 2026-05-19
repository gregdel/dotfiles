// Reusable popup menu row: polled icon + static label
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: menuBtn
    property string iconProc: ""    // command to poll for icon text
    property string staticIcon: ""  // fixed icon (if iconProc is empty)
    property int iconInterval: 5000
    property string label: ""

    signal activated

    implicitHeight: 38
    implicitWidth: 200

    property string currentIcon: staticIcon

    Process {
        id: iconPollProc
        command: ["sh", "-c", menuBtn.iconProc + "; echo"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => { if (data.length > 0) menuBtn.currentIcon = data }
        }
    }

    Timer {
        interval: menuBtn.iconInterval
        repeat: true
        running: menuBtn.iconProc.length > 0
        triggeredOnStart: true
        onTriggered: iconPollProc.running = true
    }

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
                text: menuBtn.currentIcon
                color: "#d0d0d0"
                font.family: "monospace"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: 22
            }

            Text {
                text: menuBtn.label
                color: "#d0d0d0"
                font.family: "monospace"
                font.pixelSize: 13
                Layout.fillWidth: true
            }
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: menuBtn.activated()
    }
}
