import QtQuick
import QtQuick.Layouts
import Quickshell

BarSection {
    id: root

    required property SystemdServiceGroup group
    required property string icon

    clickable: true

    StatText {
        text: root.icon
        color: root.group.active ? Appearance.accentColor : Appearance.inactiveColor
        font.pixelSize: Appearance.barFontSize
    }

    popup: BarPopup {
        id: menu
        cardWidth: 200
        spacing: 2

        PopupHeading {
            implicitHeight: 32
            title: root.group.title
            detail: root.group.busy ? "working…"
                : root.group.active ? root.group.serviceLabel(root.group.activeService)
                : "stopped"
        }

        Repeater {
            model: root.group.serviceOptions

            Rectangle {
                id: serviceRow

                required property var modelData
                property bool selected: root.group.activeService === modelData.name

                width: parent.width
                height: 38
                radius: 6
                color: rowMouse.containsMouse ? Appearance.hoverBackground : "transparent"
                Behavior on color { ColorAnimation { duration: Appearance.hoverDuration } }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 10
                    }
                    spacing: 8

                    Text {
                        text: serviceRow.selected ? "●" : "○"
                        color: serviceRow.selected ? Appearance.accentColor : Appearance.inactiveColor
                        font.family: Appearance.fontFamily
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: 16
                    }

                    Text {
                        text: modelData.label
                        color: serviceRow.selected ? Appearance.textColor : Appearance.textDim
                        font.family: Appearance.fontFamily
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    hoverEnabled: true
                    enabled: !root.group.busy && !serviceRow.selected
                    onClicked: {
                        menu.close()
                        root.group.switchTo(modelData.name)
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 38
            radius: 6
            color: stopMouse.containsMouse ? Appearance.hoverBackground : "transparent"
            Behavior on color { ColorAnimation { duration: Appearance.hoverDuration } }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: 10
                }
                spacing: 8

                Text {
                    text: "■"
                    color: root.group.active ? Appearance.dangerColor : Appearance.inactiveColor
                    font.family: Appearance.fontFamily
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 16
                }

                Text {
                    text: "Stop server"
                    color: root.group.active ? Appearance.textColor : Appearance.textFaint
                    font.family: Appearance.fontFamily
                    font.pixelSize: 13
                    Layout.fillWidth: true
                }
            }

            MouseArea {
                id: stopMouse
                anchors.fill: parent
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                hoverEnabled: true
                enabled: root.group.active && !root.group.busy
                onClicked: {
                    menu.close()
                    root.group.stopServices()
                }
            }
        }
    }
}
