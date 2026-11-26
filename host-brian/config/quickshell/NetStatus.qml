import QtQuick
import QtQuick.Layouts

BarSection {
    id: root

    // Shared scale so download and upload lines are comparable.
    readonly property real scale: Math.max(64 * 1024, ...Stats.netRxHistory, ...Stats.netTxHistory) * 1.15
    readonly property real busy: 1024 * 1024

    component RateGraph: Item {
        Sparkline {
            anchors.fill: parent
            values: Stats.netRxHistory
            maxValue: root.scale
            color: Appearance.graphColor
        }

        Sparkline {
            anchors.fill: parent
            values: Stats.netTxHistory
            maxValue: root.scale
            fill: false
            showDot: false
            lineWidth: 1
            color: Appearance.infoColor
        }
    }

    RateGraph {
        implicitWidth: 56
        implicitHeight: 20
    }

    StatText { text: "↓"; color: Appearance.graphColor }

    StatText {
        text: Stats.rate(Stats.netRx)
        color: Stats.netRx >= root.busy ? Appearance.textColor : Appearance.textDim
    }

    StatText { text: "↑"; color: Appearance.infoColor }

    StatText {
        text: Stats.rate(Stats.netTx)
        color: Stats.netTx >= root.busy ? Appearance.textColor : Appearance.textDim
    }

    popup: BarPopup {
        cardWidth: 260
        spacing: 10

        PopupHeading {
            title: "Network"
            detail: Stats.netIface
        }

        RateGraph {
            width: parent.width
            height: 56
        }

        Grid {
            width: parent.width
            columns: 2
            columnSpacing: 16

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Down"
                value: Stats.rate(Stats.netRx).trim() + "/s"
                swatch: Appearance.graphColor
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Up"
                value: Stats.rate(Stats.netTx).trim() + "/s"
                swatch: Appearance.infoColor
            }
        }
    }
}
