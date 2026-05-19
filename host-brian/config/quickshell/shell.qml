import QtQuick
import QtQuick.Layouts
import Quickshell

ShellRoot {
    PanelWindow {
        id: bar

        anchors.top: true
        anchors.left: true
        anchors.right: true

        implicitHeight: 30
        exclusiveZone: implicitHeight

        color: "#101010"

        Item {
            anchors.fill: parent

            RowLayout {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                spacing: 0

                Workspaces {}
                Volume { barWindow: bar }
                Music {}
            }

            Clock {
                anchors.centerIn: parent
            }

            RowLayout {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                spacing: 0

                SysInfo {}
                Gaming {}
                Bluetooth { barWindow: bar }
                ActionMenu { barWindow: bar }
                PowerMenu { barWindow: bar }
            }
        }
    }
}
