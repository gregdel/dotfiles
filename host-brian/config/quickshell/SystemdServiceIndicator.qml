import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property string serviceName
    required property string icon
    property string servicePattern: serviceName
    property var serviceOptions: [
        { "name": serviceName, "label": serviceName }
    ]
    property int pollInterval: 5000
    property string activeService: ""
    property string pendingService: ""
    property string actionPhase: ""
    property bool active: activeService.length > 0
    property bool busy: actionProc.running || actionPhase.length > 0

    implicitWidth: serviceIcon.implicitWidth + 20
    implicitHeight: Appearance.barHeight

    function refreshStatus() {
        if (!statusProc.running)
            statusProc.running = true
    }

    function serviceLabel(service) {
        for (let i = 0; i < serviceOptions.length; i++) {
            if (serviceOptions[i].name === service)
                return serviceOptions[i].label
        }
        return service
    }

    function switchTo(service) {
        if (busy || service === activeService)
            return

        pendingService = service

        if (active) {
            actionPhase = "stop"
            actionProc.command = [
                "systemctl", "--user", "stop", servicePattern
            ]
        } else {
            actionPhase = "start"
            actionProc.command = [
                "systemctl", "--user", "start", pendingService
            ]
        }

        actionProc.running = true
    }

    function stopServices() {
        if (busy || !active)
            return

        pendingService = ""
        actionPhase = "stop"
        actionProc.command = [
            "systemctl", "--user", "stop", servicePattern
        ]
        actionProc.running = true
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
        onEntered: {
            closeTimer.stop()
            servicePopup.visible = true
        }
        onExited: closeTimer.restart()
        onClicked: servicePopup.visible = true
    }

    Timer {
        id: closeTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (!serviceMouse.containsMouse && !popupHover.hovered)
                servicePopup.visible = false
        }
    }

    PopupWindow {
        id: servicePopup
        visible: false

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom

        implicitWidth: 200
        implicitHeight: serviceCol.implicitHeight + 16
        color: "transparent"

        HoverHandler {
            id: popupHover
            onHoveredChanged: {
                if (hovered)
                    closeTimer.stop()
                else
                    closeTimer.restart()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Appearance.popupBackground
            radius: Appearance.popupRadius
            antialiasing: true
            clip: true
            border.width: 1
            border.color: Appearance.popupBorder

            Column {
                id: serviceCol
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 8
                }
                spacing: 2

                Text {
                    width: parent.width
                    height: 30
                    text: root.active
                        ? root.serviceLabel(root.activeService) + " active"
                        : "llama.cpp stopped"
                    color: root.active ? "#c4a000" : "#808080"
                    font.family: "monospace"
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }

                Repeater {
                    model: root.serviceOptions

                    Rectangle {
                        id: serviceRow

                        required property var modelData
                        property bool selected: root.activeService === modelData.name

                        width: serviceCol.width
                        height: 38
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
                                text: serviceRow.selected ? "●" : "○"
                                color: serviceRow.selected ? "#c4a000" : "#505050"
                                font.family: "monospace"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                Layout.preferredWidth: 16
                            }

                            Text {
                                text: modelData.label
                                color: serviceRow.selected ? "#d0d0d0" : "#909090"
                                font.family: "monospace"
                                font.pixelSize: 13
                                Layout.fillWidth: true
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            hoverEnabled: true
                            enabled: !root.busy && !serviceRow.selected
                            onClicked: {
                                servicePopup.visible = false
                                root.switchTo(modelData.name)
                            }
                        }
                    }
                }

                Rectangle {
                    id: stopRow

                    width: serviceCol.width
                    height: 38
                    radius: 6
                    color: stopMouse.containsMouse ? "#282828" : "transparent"

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        spacing: 8

                        Text {
                            text: "■"
                            color: root.active ? "#a04040" : "#505050"
                            font.family: "monospace"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            Layout.preferredWidth: 16
                        }

                        Text {
                            text: "Stop server"
                            color: root.active ? "#d0d0d0" : "#606060"
                            font.family: "monospace"
                            font.pixelSize: 13
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: stopMouse
                        anchors.fill: parent
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        hoverEnabled: true
                        enabled: root.active && !root.busy
                        onClicked: {
                            servicePopup.visible = false
                            root.stopServices()
                        }
                    }
                }
            }
        }
    }

    Process {
        id: statusProc
        command: [
            "systemctl", "--user", "list-units", "--state=active",
            "--plain", "--no-legend", "--no-pager", root.servicePattern
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                let activeService = ""

                for (let i = 0; i < lines.length && activeService.length === 0; i++) {
                    const unit = lines[i].trim().split(/\s+/)[0]
                    for (let j = 0; j < root.serviceOptions.length; j++) {
                        if (unit === root.serviceOptions[j].name) {
                            activeService = unit
                            break
                        }
                    }
                }

                root.activeService = activeService
            }
        }
    }

    Process {
        id: actionProc
        stderr: StdioCollector {
            onStreamFinished: {
                const message = text.trim()
                if (message.length > 0)
                    console.warn("Service action failed:", message)
            }
        }
        onRunningChanged: {
            if (running)
                return

            if (root.actionPhase === "stop" && root.pendingService.length > 0) {
                root.actionPhase = "start"
                command = [
                    "systemctl", "--user", "start", root.pendingService
                ]
                running = true
                return
            }

            root.actionPhase = ""
            root.pendingService = ""
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
