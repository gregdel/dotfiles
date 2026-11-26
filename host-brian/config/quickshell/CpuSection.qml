import QtQuick
import QtQuick.Layouts

BarSection {
    id: root

    // Graph shape shows load; its colour shows heat.
    readonly property color tint: Stats.heatColor(Stats.cpuHeat, Appearance.graphColor)

    StatText {
        text: ""
        color: Appearance.textFaint
        font.pixelSize: Appearance.barFontSize
    }

    Sparkline {
        values: Stats.cpuHistory
        color: root.tint
    }

    StatText { text: Stats.percent(Stats.cpuLoad) }

    StatText {
        text: Stats.degrees(Stats.cpuTemp)
        color: Stats.heatColor(Stats.cpuHeat, Appearance.textDim)
    }

    popup: BarPopup {
        cardWidth: 300
        spacing: 10

        PopupHeading {
            title: "CPU"
            detail: Stats.cpuModel
        }

        Item {
            width: parent.width
            height: 64

            Sparkline {
                anchors.fill: parent
                grid: true
                values: Stats.cpuHistory
                color: Appearance.textColor
                fillOpacity: 0.18
            }

            Sparkline {
                anchors.fill: parent
                values: Stats.cpuTempHistory
                minValue: 30
                maxValue: 100
                fill: false
                showDot: false
                lineWidth: 1
                color: Appearance.accentColor
            }
        }

        Grid {
            width: parent.width
            columns: 2
            columnSpacing: 16

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Load"
                value: Stats.percent(Stats.cpuLoad).trim()
                swatch: Appearance.textColor
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Temp"
                value: Stats.degrees(Stats.cpuTemp)
                valueColor: Stats.heatColor(Stats.cpuHeat, Appearance.textColor)
                swatch: Appearance.accentColor
            }
        }

        PopupCaption {
            text: Stats.coreLoads.length + " threads"
        }

        Row {
            id: cores

            readonly property int count: Stats.coreLoads.length

            width: parent.width
            height: 32
            spacing: 3

            Repeater {
                model: cores.count

                Item {
                    required property int index
                    readonly property real load: Stats.coreLoads[index] ?? 0

                    width: (cores.width - cores.spacing * (cores.count - 1)) / cores.count
                    height: cores.height

                    Rectangle {
                        anchors.fill: parent
                        radius: 2
                        color: Appearance.meterTrack
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Math.max(2, parent.height * parent.load / 100)
                        radius: 2
                        color: parent.load >= 90 ? Appearance.textColor : Appearance.graphColor

                        Behavior on height { NumberAnimation { duration: Appearance.meterDuration; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }
    }
}
