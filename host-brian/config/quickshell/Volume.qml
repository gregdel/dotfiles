import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    property var barWindow

    implicitWidth: volText.implicitWidth + 20
    implicitHeight: 30

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink
    property string name: {
        if (sink == null)           return "󰖁"
        if (sink.nickname != "")    return sink.nickname
        if (sink.description != "") return sink.description
        if (sink.name != "")        return sink.name
        return " Unknown"
    }
    property bool muted: sink?.audio?.muted ?? false
    property real volume: sink?.audio?.volume ?? 0.0
    property int pct: Math.round(volume * 100)

    property string icon: {
        if (muted) return "󰝟"
        if (pct < 20) return ""
        if (pct < 60) return ""
        return ""
    }

    Text {
        id: volText
        anchors.centerIn: parent
        text: name + " " + icon  + " " + pct + "%"
        color: muted ? "#505050" : "#d0d0d0"
        font.family: "monospace"
        font.pixelSize: 14
    }

    MouseArea {
        anchors.fill: parent
        onWheel: event => {
            if (!sink?.audio || !sink.ready) return
            var delta = event.angleDelta.y > 0 ? 0.05 : -0.05
            sink.audio.volume = Math.max(0.0, Math.min(1.3, sink.audio.volume + delta))
        }
        onClicked: {
            if (sink?.audio && sink.ready)
                sink.audio.muted = !sink.audio.muted
        }
    }
}
