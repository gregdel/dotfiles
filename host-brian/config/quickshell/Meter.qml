// Thin horizontal fill meter; value is a 0..1 fraction (negative = unknown).
import QtQuick

Item {
    id: root

    property real value: -1
    property color color: Appearance.graphColor

    implicitWidth: 56
    implicitHeight: 4

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Appearance.meterTrack
    }

    Rectangle {
        visible: root.value > 0
        height: parent.height
        width: Math.max(height, parent.width * Math.min(1, Math.max(0, root.value)))
        radius: height / 2
        color: root.color

        Behavior on width { NumberAnimation { duration: Appearance.meterDuration; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: Appearance.meterDuration } }
    }
}
