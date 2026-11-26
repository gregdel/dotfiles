import QtQuick
import Quickshell

Text {
    color: Appearance.textColor
    font.family: Appearance.barFontFamily
    font.pixelSize: Appearance.barFontSize
    font.bold: true

    text: Qt.formatDateTime(clock.date, "ddd dd MMM  hh:mm")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
