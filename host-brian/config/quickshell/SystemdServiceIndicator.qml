import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property string serviceName
    required property string icon
    property int pollInterval: 5000
    property bool active: false

    implicitWidth: serviceIcon.implicitWidth + 20
    implicitHeight: Appearance.barHeight

    function refreshStatus() {
        if (!statusProc.running)
            statusProc.running = true
    }

    Rectangle {
        anchors {
            fill: parent
            topMargin: 4
            bottomMargin: 4
            leftMargin: 3
            rightMargin: 3
        }
        radius: 6
        color: serviceMouse.containsMouse ? "#202020" : "transparent"
    }

    Text {
        id: serviceIcon
        anchors.centerIn: parent
        text: root.icon
        color: root.active ? "#c4a000" : "#505050"
        font.family: Appearance.barFontFamily
        font.pixelSize: Appearance.barFontSize
    }

    MouseArea {
        id: serviceMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        enabled: !actionProc.running
        onClicked: {
            actionProc.command = [
                "systemctl",
                "--user",
                root.active ? "stop" : "start",
                root.serviceName
            ]
            actionProc.running = true
        }
    }

    Process {
        id: statusProc
        command: ["systemctl", "--user", "is-active", root.serviceName]
        stdout: StdioCollector {
            onStreamFinished: root.active = text.trim() === "active"
        }
    }

    Process {
        id: actionProc
        onRunningChanged: {
            if (!running)
                root.refreshStatus()
        }
    }

    Timer {
        interval: root.pollInterval
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refreshStatus()
    }
}
