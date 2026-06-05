import QtQuick
import QtQuick.Layouts
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData

            screen: modelData

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

                    Workspaces { screen: bar.screen }
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

                    Volume { barWindow: bar }
                    SysInfo {}
                    Gaming {}
                    Bluetooth { barWindow: bar }
                    ActionMenu { barWindow: bar }
                    PowerMenu { barWindow: bar }
                }
            }
        }
    }
}
