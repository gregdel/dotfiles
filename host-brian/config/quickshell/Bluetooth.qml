import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

Item {
    id: root
    property var barWindow

    implicitWidth: btLabel.implicitWidth + 24
    implicitHeight: 30

    property var adapter: Bluetooth.defaultAdapter
    property bool btEnabled: adapter?.enabled ?? false

    property int connectedCount: {
        if (!adapter?.devices) return 0
        var count = 0
        var devs = adapter.devices.values
        for (var i = 0; i < devs.length; i++) {
            if (devs[i]?.connected) count++
        }
        return count
    }

    Text {
        id: btLabel
        anchors.centerIn: parent
        text: !root.btEnabled ? "󰂲" : (root.connectedCount > 0 ? "󰂱" : "󰂯")
        color: root.connectedCount > 0 ? "#d0d0d0" : "#505050"
        font.family: "monospace"
        font.pixelSize: 14
    }

    MouseArea {
        anchors.fill: parent
        onClicked: btPopup.visible = !btPopup.visible
    }

    PopupWindow {
        id: btPopup
        visible: false

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom

        implicitWidth: 220
        implicitHeight: btCol.implicitHeight + 16
        color: "#202020"

        Column {
            id: btCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 8
            }
            spacing: 4

            RowLayout {
                width: parent.width
                height: 32

                Text {
                    text: "Bluetooth"
                    color: "#d0d0d0"
                    font.family: "monospace"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 44
                    height: 24
                    radius: 12
                    color: root.btEnabled ? "#c4a000" : "#505050"

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: "#d0d0d0"
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.btEnabled ? parent.width - width - 2 : 2
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.adapter)
                                root.adapter.enabled = !root.adapter.enabled
                        }
                    }
                }
            }

            // Paired/connected device list
            Repeater {
                model: root.adapter?.devices ?? null

                Rectangle {
                    required property var modelData
                    required property int index

                    visible: modelData.paired || modelData.connected
                    width: btCol.width
                    height: visible ? 40 : 0
                    color: deviceMouse.containsMouse ? "#282828" : "transparent"
                    radius: 6

                    RowLayout {
                        anchors { fill: parent; margins: 6 }
                        spacing: 8

                        Text {
                            text: modelData.connected ? "" : ""
                            color: modelData.connected ? "#c4a000" : "#505050"
                            font.family: "monospace"
                            font.pixelSize: 16
                        }

                        Text {
                            text: modelData.name || modelData.deviceName
                            color: "#d0d0d0"
                            font.family: "monospace"
                            font.pixelSize: 13
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: deviceMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: modelData.connected = !modelData.connected
                    }
                }
            }
        }
    }
}
