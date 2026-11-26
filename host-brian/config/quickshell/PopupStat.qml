// Label/value row for popups. A swatch colour doubles as a graph legend.
import QtQuick

Item {
    id: root

    property string label
    property string value
    property color valueColor: Appearance.textColor
    property color swatch: "transparent"

    implicitWidth: 120
    implicitHeight: 20

    Rectangle {
        id: swatchLine
        visible: root.swatch.a > 0
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        height: 2
        radius: 1
        color: root.swatch
    }

    Text {
        anchors.left: swatchLine.visible ? swatchLine.right : parent.left
        anchors.leftMargin: swatchLine.visible ? 6 : 0
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: Appearance.textDim
        font.family: Appearance.fontFamily
        font.pixelSize: 12
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.value
        color: root.valueColor
        font.family: Appearance.fontFamily
        font.pixelSize: 13

        Behavior on color { ColorAnimation { duration: Appearance.meterDuration } }
    }
}
