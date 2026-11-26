import QtQuick
import QtQuick.Layouts

BarSection {
    id: root

    // Graph shape shows load; its colour shows junction heat.
    readonly property color tint: Stats.heatColor(Stats.gpuHeat, Appearance.graphColor)

    function mhz(v) {
        return v < 0 ? "--" : v + " MHz"
    }

    StatText {
        text: String.fromCodePoint(0xF0FB2)
        color: Appearance.textFaint
        font.pixelSize: Appearance.barFontSize
    }

    Sparkline {
        values: Stats.gpuHistory
        color: root.tint
    }

    StatText { text: Stats.percent(Stats.gpuLoad) }

    StatText {
        text: Stats.degrees(Stats.gpuJunction)
        color: Stats.heatColor(Stats.gpuHeat, Appearance.textDim)
    }

    StatText {
        text: Stats.watts(Stats.gpuPower)
        color: Appearance.textFaint
    }

    popup: BarPopup {
        cardWidth: 300
        spacing: 10

        PopupHeading {
            title: "GPU"
            detail: Stats.gpuPowerCap > 0 ? Math.round(Stats.gpuPowerCap) + " W limit" : ""
        }

        Item {
            width: parent.width
            height: 64

            Sparkline {
                anchors.fill: parent
                grid: true
                values: Stats.gpuHistory
                color: Appearance.textColor
                fillOpacity: 0.18
            }

            Sparkline {
                anchors.fill: parent
                values: Stats.gpuTempHistory
                minValue: 30
                maxValue: 110
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
                value: Stats.percent(Stats.gpuLoad).trim()
                swatch: Appearance.textColor
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Junction"
                value: Stats.degrees(Stats.gpuJunction)
                valueColor: Stats.heatColor(Stats.gpuHeat, Appearance.textColor)
                swatch: Appearance.accentColor
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Edge"
                value: Stats.degrees(Stats.gpuEdge)
                valueColor: Stats.heatColor(Stats.heat(Stats.gpuEdge, 75, 85), Appearance.textColor)
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Memory"
                value: Stats.degrees(Stats.gpuMemTemp)
                valueColor: Stats.heatColor(Stats.heat(Stats.gpuMemTemp, 85, 95), Appearance.textColor)
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Power"
                value: Stats.gpuPower < 0 ? "--" : Math.round(Stats.gpuPower) + " W"
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Fan"
                value: Stats.fanRpm < 0 ? "--"
                    : Stats.fanRpm === 0 ? "stopped"
                    : Stats.fanRpm + " rpm"
                valueColor: Stats.fanRpm > 0 ? Appearance.textColor : Appearance.textDim
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Core"
                value: root.mhz(Stats.gpuCoreClock)
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "VRAM clk"
                value: root.mhz(Stats.gpuMemClock)
            }
        }

        PopupCaption { text: "Video memory" }

        PopupStat {
            width: parent.width
            label: "Used"
            value: Stats.gib(Stats.vramUsed) + " / " + Stats.gib(Stats.vramTotal) + " GiB"
        }

        Meter {
            width: parent.width
            height: 6
            value: Stats.vramFraction
            color: Stats.fillColor(Stats.vramFraction, Appearance.infoColor)
        }
    }
}
