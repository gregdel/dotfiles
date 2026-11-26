import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3

ShellRoot {
    SystemdServiceGroup {
        id: llamaCpp
        title: "llama.cpp"
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
    }

    Connections {
        target: I3

        function onRawEvent(event) {
            if (event.type === "output")
                I3.refreshMonitors()
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData
            property bool portrait: modelData.height > modelData.width
            // Read by BarPopup to continue the focus line around popups.
            readonly property bool outputFocused: !!I3.focusedMonitor
                && I3.focusedMonitor.name === modelData.name

            screen: modelData

            anchors.top: !portrait
            anchors.bottom: portrait
            anchors.left: true
            anchors.right: true

            implicitHeight: Appearance.barHeight
            exclusiveZone: implicitHeight

            color: Appearance.barBackground

            // Loaders so the hidden layout's pollers are not instantiated.
            Loader {
                anchors.fill: parent
                active: !bar.portrait
                sourceComponent: Item {
                    RowLayout {
                        id: leftRow
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        spacing: 0

                        Workspaces { screen: bar.screen }
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

                        Music { maxTextWidth: bar.width / 3 - 20 }
                        SystemdServiceIndicator {
                            group: llamaCpp
                            icon: ""
                        }
                        Volume {}
                        Gaming {}
                        Bluetooth {}
                        ActionMenu {}
                        PowerMenu {}
                    }
                }
            }

            Loader {
                anchors.fill: parent
                active: bar.portrait
                sourceComponent: Item {
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

                    RowLayout {
                        anchors {
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                        }
                        spacing: 0

                        LlamaStatus {
                            visible: llamaCpp.active
                            group: llamaCpp
                        }
                        NetStatus {
                            visible: !llamaCpp.active
                        }
                    }
                }
            }

            // Focus line along the edge facing the screen's windows.
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                y: bar.portrait ? 0 : parent.height - height
                height: Appearance.focusLineWidth
                color: Appearance.focusLineColor
                opacity: bar.outputFocused ? 1 : 0

                Behavior on opacity { NumberAnimation { duration: Appearance.hoverDuration * 2 } }
            }
        }
    }
}
