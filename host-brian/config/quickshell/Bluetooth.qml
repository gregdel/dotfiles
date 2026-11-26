import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

BarSection {
    id: root

    clickable: true

    property var adapter: Bluetooth.defaultAdapter
    property bool btEnabled: adapter && adapter.enabled

    property int connectedCount: {
        if (!adapter || !adapter.devices) return 0
        var count = 0
        var devs = adapter.devices.values
        for (var i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].connected) count++
        }
        return count
    }

    StatText {
        id: btLabel
        text: !root.btEnabled ? "󰂲" : (root.connectedCount > 0 ? "󰂱" : "󰂯")
        color: root.connectedCount > 0 ? Appearance.textColor : Appearance.inactiveColor
        font.pixelSize: Appearance.barFontSize
    }

    popup: BarPopup {
        cardWidth: 220
        spacing: 2

        Item {
            width: parent.width
            implicitHeight: 32

            PopupHeading {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - toggle.width - 12
                title: "Bluetooth"
                detail: !root.btEnabled ? "off"
                    : root.connectedCount > 0 ? root.connectedCount + " connected"
                    : ""
            }

            Rectangle {
                id: toggle
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 24
                radius: 12
                color: root.btEnabled ? Appearance.accentColor : Appearance.inactiveColor

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: Appearance.textColor
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.btEnabled ? parent.width - width - 2 : 2
                    Behavior on x { NumberAnimation { duration: 150 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.adapter)
                            root.adapter.enabled = !root.adapter.enabled
                    }
                }
            }
        }

        Repeater {
            model: root.adapter && root.adapter.devices ? root.adapter.devices : null

            Rectangle {
                required property var modelData
                required property int index

                visible: modelData.paired || modelData.connected
                width: parent.width
                height: 38
                color: deviceMouse.containsMouse ? Appearance.hoverBackground : "transparent"
                Behavior on color { ColorAnimation { duration: Appearance.hoverDuration } }
                radius: 6

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 10
                    }
                    spacing: 8

                    Text {
                        text: modelData.connected ? "●" : "○"
                        color: modelData.connected ? Appearance.accentColor : Appearance.inactiveColor
                        font.family: Appearance.fontFamily
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: 14
                    }

                    Text {
                        text: modelData.name || modelData.deviceName
                        color: modelData.connected ? Appearance.textColor : Appearance.textDim
                        font.family: Appearance.fontFamily
                        font.pixelSize: 13
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: deviceMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: modelData.connected = !modelData.connected
                }
            }
        }
    }
}
