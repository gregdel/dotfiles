import QtQuick
import Quickshell
import Quickshell.Services.Mpris

PopupWindow {
    id: musicPopup
    property var player
    property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    visible: false
    implicitWidth: 280
    implicitHeight: popupCol.implicitHeight + 24
    color: "#202020"

    onPlayerChanged: {
        if (!player) visible = false
        else currentPosition = player.position
    }
    onVisibleChanged: { if (visible && player) currentPosition = player.position }

    property real currentPosition: 0

    HoverHandler {
        onHoveredChanged: if (!hovered) musicPopup.visible = false
    }

    Timer {
        interval: 1000
        repeat: true
        running: musicPopup.visible && (player?.length ?? 0) > 0
        onTriggered: currentPosition = player?.position ?? currentPosition
    }

    function formatTime(ms) {
        var s = Math.floor(Math.max(0, ms) / 1000)
        var m = Math.floor(s / 60)
        s = s % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    Column {
        id: popupCol
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 12
        }
        spacing: 10

        // --- Header row (album art + title/artist) ---
        Row {
            width: parent.width
            spacing: 12

            Item {
                width: 64
                height: 64
                clip: true

                Image {
                    id: albumArt
                    anchors.fill: parent
                    source: player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    visible: (player?.trackArtUrl ?? "") !== "" && status !== Image.Error
                }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: "monospace"
                    font.pixelSize: 32
                    color: "#606060"
                    visible: !albumArt.visible
                }
            }

            Column {
                width: parent.width - 64 - parent.spacing
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    width: parent.width
                    text: player?.trackTitle ?? ""
                    color: "#e0e0e0"
                    font.family: "monospace"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: player?.trackArtist ?? ""
                    color: "#909090"
                    font.family: "monospace"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }
        }

        // --- Seek bar ---
        Column {
            width: parent.width
            spacing: 4

            Item {
                width: parent.width
                height: 4

                Rectangle {
                    id: seekBg
                    anchors.fill: parent
                    color: "#383838"
                    radius: 2

                    Rectangle {
                        width: (player?.length ?? 0) > 0
                            ? seekBg.width * Math.min(currentPosition, player?.length ?? 0) / (player?.length ?? 1)
                            : 0
                        height: parent.height
                        color: "#c4a000"
                        radius: 2
                    }
                }

                MouseArea {
                    anchors.fill: seekBg
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.NoButton
                    onClicked: mouse => {
                        if (player && (player.length ?? 0) > 0)
                            player.position = (mouseX / seekBg.width) * player.length
                    }
                }
            }

            Item {
                width: parent.width
                height: timeElapsed.implicitHeight

                Text {
                    id: timeElapsed
                    anchors.left: parent.left
                    text: formatTime(currentPosition)
                    color: "#606060"
                    font.family: "monospace"
                    font.pixelSize: 11
                }

                Text {
                    anchors.right: parent.right
                    text: formatTime(player?.length ?? 0)
                    color: "#606060"
                    font.family: "monospace"
                    font.pixelSize: 11
                }
            }
        }

        // --- Transport controls ---
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 24

            Item {
                width: 36
                height: 36

                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    font.family: "monospace"
                    font.pixelSize: 24
                    color: prevMouse.containsMouse ? "#c4a000" : "#d0d0d0"
                }

                MouseArea {
                    id: prevMouse
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.NoButton
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: player?.previous()
                }
            }

            Item {
                width: 36
                height: 36

                Text {
                    anchors.centerIn: parent
                    text: (player?.playbackState === MprisPlaybackState.Playing) ? "󰏤" : "󰐊"
                    font.family: "monospace"
                    font.pixelSize: 18
                    color: playMouse.containsMouse ? "#c4a000" : "#d0d0d0"
                }

                MouseArea {
                    id: playMouse
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.NoButton
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: player?.togglePlaying()
                }
            }

            Item {
                width: 36
                height: 36

                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    font.family: "monospace"
                    font.pixelSize: 18
                    color: nextMouse.containsMouse ? "#c4a000" : "#d0d0d0"
                }

                MouseArea {
                    id: nextMouse
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.NoButton
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: player?.next()
                }
            }
        }
    }
}
