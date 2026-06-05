import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: root

    implicitWidth: musicText.implicitWidth + 20
    implicitHeight: 30

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
        return name
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

    Text {
        id: musicText
        anchors.centerIn: parent
        text: trackText
        color: playing ? "#d0d0d0" : "#909090"
        font.family: "monospace"
        font.pixelSize: 14
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: !!currentPlayer
        onClicked: musicPopup.visible = !musicPopup.visible
    }

    MusicPopup {
        id: musicPopup
        player: currentPlayer
        anchorItem: root
    }
}
