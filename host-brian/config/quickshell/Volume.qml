import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

BarSection {
    id: root

    clickable: true
    spacing: 6

    onClicked: {
        if (root.hasSink)
            sink.audio.muted = !sink.audio.muted
    }

    onScrolled: wheel => {
        if (!root.hasSink)
            return
        var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
        sink.audio.volume = Math.max(0.0, Math.min(1.3, sink.audio.volume + delta))
    }

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

    StatText {
        text: root.outputIcon
        color: root.muted || !root.hasSink ? Appearance.inactiveColor : Appearance.textDim
        font.pixelSize: Appearance.barFontSize
    }

    StatText {
        // Padded so the bar doesn't shift between 5% and 100%.
        text: root.volumeIcon + " " + String(root.pct).padStart(3, " ") + "%"
        color: root.muted || !root.hasSink ? Appearance.inactiveColor : Appearance.textColor
        font.pixelSize: Appearance.barFontSize
    }
}
