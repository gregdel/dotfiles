import QtQuick

Text {
    color: "#d0d0d0"
    font.family: Appearance.barFontFamily
    font.pixelSize: Appearance.barFontSize
    font.bold: true

    text: Qt.formatDateTime(new Date(), "ddd dd MMM  hh:mm")

    Timer {
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: parent.text = Qt.formatDateTime(new Date(), "ddd dd MMM  hh:mm")
    }
}
