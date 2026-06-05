import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root
    property var barWindow

    implicitWidth: volumeRow.implicitWidth + 22
    implicitHeight: 30

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink
    property bool hasSink: sink != null && sink.ready && sink.audio != null
    property string sinkName: sink ? sink.name : ""
    property string sinkNickname: sink ? sink.nickname : ""
    property string sinkDescription: sink ? sink.description : ""
    property bool muted: hasSink ? sink.audio.muted : false
    property real volume: hasSink ? sink.audio.volume : 0.0
    property int pct: Math.round(volume * 100)

    property string outputIcon: {
        if (sinkName.indexOf("bluez_output.AC_BF_71_E7_B2_55.1") >= 0)
            return "󰋋"
        if (sinkName.indexOf("hdmi-stereo-extra4") >= 0)
            return ""
        if (sinkName.indexOf("hdmi-stereo-extra2") >= 0)
            return "󰍹"
        if (sinkName.indexOf("bluez_output") >= 0 || sinkDescription.indexOf("Bluetooth") >= 0)
            return "󰋋"
        if (sinkNickname.indexOf("SAMSUNG") >= 0 || sinkDescription.indexOf("Samsung") >= 0)
            return ""
        if (sinkNickname.indexOf("DELL") >= 0 || sinkDescription.indexOf("DELL") >= 0)
            return "󰍹"
        return "󰕾"
    }

    property string volumeIcon: {
        if (!hasSink) return "󰖁"
        if (muted) return "󰝟"
        if (pct < 20) return ""
        if (pct < 60) return ""
        return ""
    }

    Rectangle {
        anchors {
            fill: parent
            topMargin: 4
            bottomMargin: 4
            leftMargin: 3
            rightMargin: 3
        }
        radius: 6
        color: volMouse.containsMouse ? "#202020" : "transparent"
    }

    Row {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.outputIcon
            color: root.muted || !root.hasSink ? "#505050" : "#909090"
            font.family: "monospace"
            font.pixelSize: 14
        }

        Text {
            id: volText
            text: root.volumeIcon + " " + root.pct + "%"
            color: root.muted || !root.hasSink
                ? "#505050"
                : (volMouse.containsMouse ? "#c4a000" : "#d0d0d0")
            font.family: "monospace"
            font.pixelSize: 14
        }
    }

    MouseArea {
        id: volMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onWheel: event => {
            if (!root.hasSink) return
            var delta = event.angleDelta.y > 0 ? 0.05 : -0.05
            sink.audio.volume = Math.max(0.0, Math.min(1.3, sink.audio.volume + delta))
        }
        onClicked: {
            if (root.hasSink)
                sink.audio.muted = !sink.audio.muted
        }
    }
}
