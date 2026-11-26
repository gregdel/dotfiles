// Popup title with a dim detail line aligned right.
import QtQuick

Item {
    id: root

    property string title
    property string detail

    width: parent ? parent.width : 0
    implicitHeight: 24

    Text {
        id: titleText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        color: Appearance.textColor
        font.family: Appearance.fontFamily
        font.pixelSize: 14
        font.bold: true
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - titleText.implicitWidth - 12
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideLeft
        text: root.detail
        color: Appearance.textFaint
        font.family: Appearance.fontFamily
        font.pixelSize: 11
    }
}
