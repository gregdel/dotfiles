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
    color: "transparent"

    onPlayerChanged: {
        if (!player) visible = false
        else currentPosition = player.position
    }
    onVisibleChanged: { if (visible && player) currentPosition = player.position }

    property real currentPosition: 0
    property real playerLength: player ? player.length : 0
    property string artUrl: player && player.trackArtUrl ? player.trackArtUrl : ""
    property string title: player && player.trackTitle ? player.trackTitle : ""
    property string artist: player && player.trackArtist ? player.trackArtist : ""
    property bool playing: player && player.playbackState === MprisPlaybackState.Playing

    HoverHandler {
        onHoveredChanged: if (!hovered) musicPopup.visible = false
    }

    Timer {
        interval: 1000
        repeat: true
        running: musicPopup.visible && playerLength > 0
        onTriggered: currentPosition = player ? player.position : currentPosition
    }

    function formatTime(ms) {
        var s = Math.floor(Math.max(0, ms) / 1000)
        var m = Math.floor(s / 60)
        s = s % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    Rectangle {
        anchors.fill: parent
        color: "#202020"
        radius: 8
        antialiasing: true
        clip: true
        border.width: 1
        border.color: "#303030"

        Column {
            id: popupCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 12
            }
            spacing: 10

            Row {
                width: parent.width
                spacing: 12

                Item {
                    width: 64
                    height: 64
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        color: "#181818"
                        radius: 6
                    }

                    Image {
                        id: albumArt
                        anchors.fill: parent
                        source: musicPopup.artUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: musicPopup.artUrl !== "" && status !== Image.Error
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰝚"
                        font.family: "monospace"
                        font.pixelSize: 28
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
                        text: musicPopup.title
                        color: "#e0e0e0"
                        font.family: "monospace"
                        font.pixelSize: 14
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: musicPopup.artist
                        color: "#909090"
                        font.family: "monospace"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                }
            }

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
                            width: playerLength > 0
                                ? seekBg.width * Math.min(currentPosition, playerLength) / playerLength
                                : 0
                            height: parent.height
                            color: "#c4a000"
                            radius: 2
                        }
                    }

                    MouseArea {
                        anchors.fill: seekBg
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton
                        onClicked: mouse => {
                            if (player && playerLength > 0)
                                player.position = (mouseX / seekBg.width) * playerLength
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
                        text: formatTime(playerLength)
                        color: "#606060"
                        font.family: "monospace"
                        font.pixelSize: 11
                    }
                }
            }

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
                        acceptedButtons: Qt.LeftButton
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: if (player) player.previous()
                    }
                }

                Item {
                    width: 36
                    height: 36

                    Text {
                        anchors.centerIn: parent
                        text: musicPopup.playing ? "󰏤" : "󰐊"
                        font.family: "monospace"
                        font.pixelSize: 18
                        color: playMouse.containsMouse ? "#c4a000" : "#d0d0d0"
                    }

                    MouseArea {
                        id: playMouse
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: if (player) player.togglePlaying()
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
                        acceptedButtons: Qt.LeftButton
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: if (player) player.next()
                    }
                }
            }
        }
    }
}
