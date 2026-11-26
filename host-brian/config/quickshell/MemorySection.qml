import QtQuick
import QtQuick.Layouts

BarSection {
    id: root

    function size(mib) {
        return mib >= 1024 ? Stats.gib(mib) + " GiB" : Math.round(mib) + " MiB"
    }

    StatText {
        text: String.fromCodePoint(0xF035B)
        color: Appearance.textFaint
        font.pixelSize: Appearance.barFontSize
    }

    // RAM over VRAM, as two stacked meters.
    GridLayout {
        columns: 2
        rowSpacing: 1
        columnSpacing: 6

        Meter {
            value: Stats.memFraction
            color: Stats.fillColor(Stats.memFraction, Appearance.graphColor)
        }

        StatText {
            text: Stats.percent(Stats.memFraction < 0 ? -1 : Stats.memFraction * 100)
            color: Appearance.textDim
            font.pixelSize: 11
        }

        Meter {
            value: Stats.vramFraction
            color: Stats.fillColor(Stats.vramFraction, Appearance.infoColor)
        }

        StatText {
            text: Stats.percent(Stats.vramFraction < 0 ? -1 : Stats.vramFraction * 100)
            color: Appearance.textDim
            font.pixelSize: 11
        }
    }

    popup: BarPopup {
        cardWidth: 280
        spacing: 8

        PopupHeading {
            title: "Memory"
            detail: Stats.memTotal > 0 ? root.size(Stats.memTotal) + " installed" : ""
        }

        PopupStat {
            width: parent.width
            label: "RAM"
            value: Stats.gib(Stats.memUsed) + " / " + Stats.gib(Stats.memTotal) + " GiB"
            swatch: Appearance.graphColor
        }

        Meter {
            width: parent.width
            height: 6
            value: Stats.memFraction
            color: Stats.fillColor(Stats.memFraction, Appearance.graphColor)
        }

        PopupStat {
            width: parent.width
            visible: Stats.swapTotal > 0
            label: "Swap"
            value: root.size(Math.max(0, Stats.swapUsed)) + " / " + Stats.gib(Stats.swapTotal) + " GiB"
            valueColor: Stats.swapUsed > 0 ? Appearance.textColor : Appearance.textDim
        }

        Meter {
            width: parent.width
            height: 6
            visible: Stats.swapTotal > 0
            value: Stats.swapTotal > 0 ? Stats.swapUsed / Stats.swapTotal : -1
            color: Appearance.graphColor
        }

        PopupStat {
            width: parent.width
            label: "VRAM"
            value: Stats.gib(Stats.vramUsed) + " / " + Stats.gib(Stats.vramTotal) + " GiB"
            swatch: Appearance.infoColor
        }

        Meter {
            width: parent.width
            height: 6
            value: Stats.vramFraction
            color: Stats.fillColor(Stats.vramFraction, Appearance.infoColor)
        }

        PopupCaption { text: "Top processes" }

        Repeater {
            model: Stats.topMemory

            PopupStat {
                required property var modelData
                width: parent.width
                label: modelData.name
                value: root.size(modelData.mib)
            }
        }

        Timer {
            interval: 3000
            repeat: true
            triggeredOnStart: true
            running: root.popup && root.popup.visible
            onTriggered: Stats.refreshTopMemory()
        }
    }
}
