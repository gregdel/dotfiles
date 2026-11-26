// Now-playing card: artwork and track info, a seek bar that glides between
// position updates (click or drag to seek), and transport controls with
// shuffle/loop toggles when the player supports them.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

BarPopup {
    id: musicPopup

    property var player

    cardWidth: 320
    spacing: 12

    onPlayerChanged: {
        if (!player)
            close()
    }

    readonly property real currentPosition: player ? player.position : 0
    readonly property real playerLength: player ? player.length : 0
    readonly property bool canSeek: !!player && player.canSeek && playerLength > 0
    readonly property string artUrl: player && player.trackArtUrl ? player.trackArtUrl : ""
    readonly property string title: player && player.trackTitle ? player.trackTitle
        : player ? player.identity : ""
    readonly property string artist: player && player.trackArtist ? player.trackArtist : ""
    readonly property string album: player && player.trackAlbum ? player.trackAlbum : ""
    readonly property bool playing: !!player && player.playbackState === MprisPlaybackState.Playing

    // Shown fraction: the drag preview while seeking, otherwise playback.
    readonly property real fraction: seekMouse.pressed ? seekMouse.fraction
        : playerLength > 0 ? Math.min(1, currentPosition / playerLength) : 0

    function formatTime(seconds) {
        var s = Math.floor(Math.max(0, seconds))
        var m = Math.floor(s / 60)
        s = s % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    // Round transport button; `filled` gives it a resting background.
    component ControlButton: Item {
        id: button

        property string icon
        property int iconSize: 18
        property bool filled: false
        property bool active: true
        property color iconColor: Appearance.textColor

        signal activated

        implicitWidth: 36
        implicitHeight: 36
        opacity: active ? 1 : 0.35

        Behavior on opacity { NumberAnimation { duration: Appearance.hoverDuration } }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: buttonMouse.containsMouse && button.active
                ? (button.filled ? Appearance.controlHoverBackground : Appearance.hoverBackground)
                : (button.filled ? Appearance.controlBackground : "transparent")

            Behavior on color { ColorAnimation { duration: Appearance.hoverDuration } }
        }

        Text {
            anchors.centerIn: parent
            text: button.icon
            color: button.iconColor
            font.family: Appearance.fontFamily
            font.pixelSize: button.iconSize

            Behavior on color { ColorAnimation { duration: Appearance.hoverDuration } }
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            enabled: button.active
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: button.activated()
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: musicPopup.visible && musicPopup.playing && musicPopup.playerLength > 0
        onTriggered: musicPopup.player.positionChanged()
    }

    // Header: clicking it brings the player's window forward.
    Item {
        width: parent.width
        implicitHeight: 24

        PopupHeading {
            anchors.fill: parent
            title: "Now playing"
            detail: musicPopup.player
                ? musicPopup.player.identity + (musicPopup.player.canRaise ? "  ↗" : "")
                : ""
        }

        MouseArea {
            anchors.fill: parent
            enabled: !!musicPopup.player && musicPopup.player.canRaise
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                musicPopup.player.raise()
                musicPopup.close()
            }
        }
    }

    RowLayout {
        width: parent.width
        spacing: 14

        ClippingRectangle {
            Layout.preferredWidth: 88
            Layout.preferredHeight: 88
            radius: 8
            color: Appearance.meterTrack

            Text {
                anchors.centerIn: parent
                visible: albumArt.status !== Image.Ready
                text: String.fromCodePoint(0xF075A)
                color: Appearance.textFaint
                font.family: Appearance.fontFamily
                font.pixelSize: 32
            }

            Image {
                id: albumArt
                anchors.fill: parent
                source: musicPopup.artUrl
                sourceSize.width: 176
                sourceSize.height: 176
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                opacity: status === Image.Ready ? 1 : 0

                Behavior on opacity { NumberAnimation { duration: Appearance.popupOpenDuration } }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 3

            Text {
                Layout.fillWidth: true
                text: musicPopup.title
                color: Appearance.textBright
                font.family: Appearance.fontFamily
                font.pixelSize: 15
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: musicPopup.artist
                color: Appearance.textDim
                font.family: Appearance.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: musicPopup.album
                color: Appearance.textFaint
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }

    Column {
        width: parent.width
        spacing: 4
        visible: musicPopup.playerLength > 0

        // Seek bar; the hit area is taller than the track.
        Item {
            id: seek

            readonly property bool engaged: seekMouse.containsMouse || seekMouse.pressed

            width: parent.width
            height: 14

            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: seek.engaged ? 6 : 4
                radius: height / 2
                color: Appearance.meterTrack

                Behavior on height { NumberAnimation { duration: Appearance.hoverDuration } }

                Rectangle {
                    height: parent.height
                    width: Math.max(height, parent.width * musicPopup.fraction)
                    radius: height / 2
                    color: Appearance.accentColor

                    // Glide between the 1 s position updates while playing.
                    Behavior on width {
                        enabled: musicPopup.playing && !seekMouse.pressed
                        NumberAnimation { duration: 1000 }
                    }
                }
            }

            Rectangle {
                width: 12
                height: 12
                radius: 6
                anchors.verticalCenter: parent.verticalCenter
                x: track.width * musicPopup.fraction - width / 2
                color: Appearance.textBright
                visible: musicPopup.canSeek
                opacity: seek.engaged ? 1 : 0
                scale: seek.engaged ? 1 : 0.5

                Behavior on opacity { NumberAnimation { duration: Appearance.hoverDuration } }
                Behavior on scale { NumberAnimation { duration: Appearance.hoverDuration } }
                Behavior on x {
                    enabled: musicPopup.playing && !seekMouse.pressed
                    NumberAnimation { duration: 1000 }
                }
            }

            MouseArea {
                id: seekMouse

                readonly property real fraction: Math.max(0, Math.min(1, mouseX / width))

                anchors.fill: parent
                enabled: musicPopup.canSeek
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                preventStealing: true
                onReleased: musicPopup.player.position = fraction * musicPopup.playerLength
            }
        }

        Item {
            width: parent.width
            height: elapsed.implicitHeight

            Text {
                id: elapsed
                anchors.left: parent.left
                text: musicPopup.formatTime(musicPopup.fraction * musicPopup.playerLength)
                color: Appearance.textFaint
                font.family: Appearance.fontFamily
                font.pixelSize: 11
            }

            Text {
                anchors.right: parent.right
                text: "-" + musicPopup.formatTime(musicPopup.playerLength * (1 - musicPopup.fraction))
                color: Appearance.textFaint
                font.family: Appearance.fontFamily
                font.pixelSize: 11
            }
        }
    }

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        ControlButton {
            implicitWidth: 30
            implicitHeight: 30
            iconSize: 14
            active: !!musicPopup.player && musicPopup.player.shuffleSupported
            icon: String.fromCodePoint(0xF049D)
            iconColor: musicPopup.player && musicPopup.player.shuffle
                ? Appearance.accentColor : Appearance.textFaint
            onActivated: musicPopup.player.shuffle = !musicPopup.player.shuffle
        }

        ControlButton {
            active: !!musicPopup.player && musicPopup.player.canGoPrevious
            icon: String.fromCodePoint(0xF04AE)
            iconSize: 20
            onActivated: musicPopup.player.previous()
        }

        ControlButton {
            implicitWidth: 46
            implicitHeight: 46
            filled: true
            active: !!musicPopup.player && musicPopup.player.canTogglePlaying
            icon: String.fromCodePoint(musicPopup.playing ? 0xF03E4 : 0xF040A)
            iconSize: 22
            iconColor: Appearance.textBright
            onActivated: musicPopup.player.togglePlaying()
        }

        ControlButton {
            active: !!musicPopup.player && musicPopup.player.canGoNext
            icon: String.fromCodePoint(0xF04AD)
            iconSize: 20
            onActivated: musicPopup.player.next()
        }

        ControlButton {
            readonly property int loop: musicPopup.player ? musicPopup.player.loopState : MprisLoopState.None

            implicitWidth: 30
            implicitHeight: 30
            iconSize: 14
            active: !!musicPopup.player && musicPopup.player.loopSupported
            icon: String.fromCodePoint(loop === MprisLoopState.Track ? 0xF0458
                : loop === MprisLoopState.Playlist ? 0xF0456
                : 0xF0457)
            iconColor: loop === MprisLoopState.None ? Appearance.textFaint : Appearance.accentColor
            // None -> Playlist -> Track -> None
            onActivated: musicPopup.player.loopState = loop === MprisLoopState.None ? MprisLoopState.Playlist
                : loop === MprisLoopState.Playlist ? MprisLoopState.Track
                : MprisLoopState.None
        }
    }
}
