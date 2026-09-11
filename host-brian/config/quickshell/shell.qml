import QtQuick
import QtQuick.Layouts
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData
            property bool portrait: modelData.height > modelData.width

            screen: modelData

            anchors.top: !portrait
            anchors.bottom: portrait
            anchors.left: true
            anchors.right: true

            implicitHeight: Appearance.barHeight
            exclusiveZone: implicitHeight

            color: "#101010"

            Item {
                anchors.fill: parent
                visible: !bar.portrait

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

                    SystemdServiceIndicator {
                        serviceName: "llama-cpp@.service"
                        icon: ""
                    }
                    Volume { barWindow: bar }
                    Gaming {}
                    Bluetooth { barWindow: bar }
                    ActionMenu { barWindow: bar }
                    PowerMenu { barWindow: bar }
                }
            }

            Item {
                anchors.fill: parent
                visible: bar.portrait

                RowLayout {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: 0

                    SysInfo {}
                }

                Workspaces {
                    anchors.centerIn: parent
                    screen: bar.screen
                }
            }
        }
    }
}
