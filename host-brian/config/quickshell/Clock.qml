import QtQuick

Text {
    color: "#d0d0d0"
    font.family: "monospace"
    font.pixelSize: 14
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
