import QtQuick
import Quickshell

BarSection {
    id: root

    // Label of the destructive action awaiting a second click.
    property string armed: ""

    clickable: true

    CommandRunner {
        id: runner
        name: "Power action"
    }

    StatText {
        text: "⏻"
        font.pixelSize: Appearance.barFontSize
    }

    popup: BarPopup {
        id: menu
        cardWidth: 140
        onVisibleChanged: if (!visible) root.armed = ""

        Repeater {
            model: [
                { label: "Suspend",  confirm: false, command: ["systemctl", "suspend"] },
                { label: "Reboot",   confirm: true,  command: ["systemctl", "reboot"] },
                { label: "Shutdown", confirm: true,  command: ["systemctl", "poweroff"] }
            ]

            Rectangle {
                required property var modelData
                property bool isArmed: root.armed === modelData.label

                width: parent.width
                height: 36
                radius: 6
                color: itemMouse.containsMouse ? Appearance.hoverBackground : "transparent"
                Behavior on color { ColorAnimation { duration: Appearance.hoverDuration } }

                Text {
                    anchors.centerIn: parent
                    text: parent.isArmed ? modelData.label + "?" : modelData.label
                    color: parent.isArmed ? Appearance.dangerColor : Appearance.textColor
                    font.family: Appearance.fontFamily
                    font.pixelSize: 13

                    Behavior on color { ColorAnimation { duration: Appearance.hoverDuration } }
                }

                MouseArea {
                    id: itemMouse
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (modelData.confirm && !parent.isArmed) {
                            root.armed = modelData.label
                            return
                        }
                        menu.close()
                        runner.run(modelData.command)
                    }
                }
            }
        }
    }
}
