import QtQuick

Item {
    implicitWidth: gamingLabel.implicitWidth + 20
    implicitHeight: Appearance.barHeight

    Text {
        id: gamingLabel
        anchors.centerIn: parent
        color: Controllers.connected ? Appearance.textColor : Appearance.inactiveColor
        font.family: Appearance.barFontFamily
        font.pixelSize: Appearance.barFontSize
        text: Controllers.connected ? Controllers.displayText : Controllers.disconnectedIcon
    }
}
