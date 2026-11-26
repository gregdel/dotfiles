import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

BarSection {
    id: root

    property real maxTextWidth: 400

    clickable: true

    // Find first playing player, fall back to first paused
    property var currentPlayer: {
        const players = Mpris.players.values
        return players.find(p => p.isPlaying)
            ?? players.find(p => p.playbackState === MprisPlaybackState.Paused)
            ?? null
    }

    property string playerIcon: {
        if (!currentPlayer) return ""
        var name = currentPlayer.identity
        if (name == "Spotify") return "󰓇"
        if (name == "mpv")     return ""
        return "󰝚"
    }

    property bool playing: {
        if (!currentPlayer) return false
        return (currentPlayer.playbackState === MprisPlaybackState.Playing)
    }

    property string trackText: {
        if (!currentPlayer) return ""
        var text = currentPlayer.trackTitle || currentPlayer.identity || "Media"
        var artist = currentPlayer.trackArtist
        if (artist != "") text = artist + "  " + text
        var state = playing ? "" : ""
        text = playerIcon + " " + state + " " + text
        return text.length > 40 ? text.substring(0, 39) + "\u2026" : text
    }

    visible: !!currentPlayer

    StatText {
        Layout.maximumWidth: root.maxTextWidth
        text: root.trackText
        elide: Text.ElideRight
        color: root.playing ? Appearance.textColor : Appearance.textDim
        font.pixelSize: Appearance.barFontSize
    }

    popup: MusicPopup {
        player: root.currentPlayer
    }
}
