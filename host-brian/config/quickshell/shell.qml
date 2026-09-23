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
                    id: leftRow
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: 0

                    Workspaces { screen: bar.screen }
                    Music { Layout.maximumWidth: bar.width / 3 }
                }

                Item {
                    anchors {
                        left: leftRow.right
                        right: rightRow.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    Clock { anchors.centerIn: parent }
                }

                RowLayout {
                    id: rightRow
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: 0

                    SystemdServiceIndicator {
                        serviceName: "llama-cpp@rocm.service"
                        servicePattern: "llama-cpp@*.service"
                        serviceOptions: [
                            {
                                "name": "llama-cpp@rocm.service",
                                "label": "ROCm"
                            },
                            {
                                "name": "llama-cpp@vulkan.service",
                                "label": "Vulkan"
                            }
                        ]
                        icon: ""
                    }
                    Volume {}
                    Gaming {}
                    Bluetooth {}
                    ActionMenu {}
                    PowerMenu {}
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
