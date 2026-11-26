// Popup that drops out of the bar next to an anchor item: same fill as the
// bar, joined to it by concave fillets, sliding out on open and back on close.
// Opens upward when the anchor's bar is docked to the bottom of the screen.
// The card overlaps the bar by the focus line's thickness, covering the line
// where it attaches; on the focused output its outline continues the line.
// Closes shortly after the pointer leaves both the popup and the anchor
// (bind anchorHovered to the anchor's hover).
import QtQuick
import QtQuick.Shapes
import Quickshell

PopupWindow {
    id: popup

    property Item anchorItem
    property bool anchorHovered: false
    property int cardWidth: 200
    property int padding: 12
    property alias spacing: content.spacing
    default property alias contentData: content.data

    // Logical state; `visible` stays true until the close animation ends.
    property bool opened: false
    property real progress: 0
    readonly property int fillet: Appearance.popupFillet

    readonly property var hostWindow: anchorItem ? anchorItem.QsWindow.window : null
    readonly property bool upward: !!hostWindow && !!hostWindow.anchors
        && hostWindow.anchors.bottom && !hostWindow.anchors.top
    // Set by the bar (shell.qml) for the output sway has focused.
    readonly property bool hostFocused: !!hostWindow && hostWindow.outputFocused === true
    readonly property int overlap: Appearance.focusLineWidth

    anchor.item: anchorItem
    anchor.edges: upward ? Edges.Top : Edges.Bottom
    anchor.gravity: upward ? Edges.Top : Edges.Bottom
    // The item's rect, minus the strip along the bar edge the card overlaps.
    anchor.rect.x: 0
    anchor.rect.y: upward ? overlap : 0
    anchor.rect.width: anchorItem ? Math.max(1, anchorItem.width) : 1
    anchor.rect.height: anchorItem ? Math.max(1, anchorItem.height - overlap) : 1

    visible: false
    implicitWidth: cardWidth + fillet * 2
    implicitHeight: content.implicitHeight + padding * 2 + overlap
    color: "transparent"

    function animateTo(target, duration, easing) {
        anim.stop()
        anim.to = target
        anim.duration = duration
        anim.easing.type = easing
        anim.start()
    }

    function open() {
        closeTimer.stop()
        opened = true
        visible = true
        animateTo(1, Appearance.popupOpenDuration, Easing.OutCubic)
    }

    function close() {
        closeTimer.stop()
        if (!opened)
            return

        opened = false
        animateTo(0, Appearance.popupCloseDuration, Easing.InCubic)
    }

    function toggle() {
        if (opened)
            close()
        else
            open()
    }

    function scheduleClose() {
        if (opened && !anchorHovered && !hover.hovered)
            closeTimer.restart()
    }

    onAnchorHoveredChanged: anchorHovered ? closeTimer.stop() : scheduleClose()

    // The compositor can dismiss the popup on its own.
    onVisibleChanged: {
        if (!visible) {
            anim.stop()
            opened = false
            progress = 0
        }
    }

    data: [
        Item {
            anchors.fill: parent
            // Hide the sheet behind the bar edge while it slides.
            clip: true

            HoverHandler {
                id: hover
                onHoveredChanged: hovered ? closeTimer.stop() : popup.scheduleClose()
            }

            Timer {
                id: closeTimer
                interval: 250
                onTriggered: {
                    if (!popup.anchorHovered && !hover.hovered)
                        popup.close()
                }
            }

            NumberAnimation {
                id: anim
                target: popup
                property: "progress"
                onFinished: {
                    if (!popup.opened)
                        popup.visible = false
                }
            }

            Item {
                width: parent.width
                height: parent.height
                y: (popup.upward ? 1 : -1) * (1 - popup.progress) * height
                opacity: popup.progress

                // Card with rounded bottom corners, flaring into the bar
                // through concave fillets at the top.
                Shape {
                    id: shape
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer
                    // Path is drawn for a top bar; mirror it to sit on a bottom bar.
                    transform: Scale {
                        origin.y: shape.height / 2
                        yScale: popup.upward ? -1 : 1
                    }

                    ShapePath {
                        id: card
                        readonly property real w: shape.width
                        readonly property real h: shape.height
                        readonly property real f: popup.fillet
                        readonly property real r: Appearance.popupRadius

                        fillColor: Appearance.popupBackground
                        strokeWidth: -1
                        startX: 0
                        startY: 0

                        PathArc { x: card.f; y: card.f; radiusX: card.f; radiusY: card.f }
                        PathLine { x: card.f; y: card.h - card.r }
                        PathArc {
                            x: card.f + card.r; y: card.h; radiusX: card.r; radiusY: card.r
                            direction: PathArc.Counterclockwise
                        }
                        PathLine { x: card.w - card.f - card.r; y: card.h }
                        PathArc {
                            x: card.w - card.f; y: card.h - card.r; radiusX: card.r; radiusY: card.r
                            direction: PathArc.Counterclockwise
                        }
                        PathLine { x: card.w - card.f; y: card.f }
                        PathArc { x: card.w; y: 0; radiusX: card.f; radiusY: card.f }
                        PathLine { x: 0; y: 0 }
                    }

                    // Continuation of the bar's focus line: it leaves the bar
                    // through the fillets, runs around the free edges and
                    // returns. Its ends sit on the overlapped strip, centred on
                    // the bar's line; the bottom is inset to stay unclipped.
                    ShapePath {
                        id: outline
                        readonly property real t: strokeWidth / 2
                        readonly property real h: card.h - t

                        fillColor: "transparent"
                        strokeColor: popup.hostFocused ? Appearance.focusLineColor : "transparent"
                        strokeWidth: popup.overlap
                        joinStyle: ShapePath.RoundJoin
                        capStyle: ShapePath.FlatCap
                        startX: 0
                        startY: outline.t

                        PathArc { x: card.f; y: card.f + outline.t; radiusX: card.f; radiusY: card.f }
                        PathLine { x: card.f; y: outline.h - card.r }
                        PathArc {
                            x: card.f + card.r; y: outline.h; radiusX: card.r; radiusY: card.r
                            direction: PathArc.Counterclockwise
                        }
                        PathLine { x: card.w - card.f - card.r; y: outline.h }
                        PathArc {
                            x: card.w - card.f; y: outline.h - card.r; radiusX: card.r; radiusY: card.r
                            direction: PathArc.Counterclockwise
                        }
                        PathLine { x: card.w - card.f; y: card.f + outline.t }
                        PathArc { x: card.w; y: outline.t; radiusX: card.f; radiusY: card.f }
                    }
                }

                Column {
                    id: content
                    x: popup.fillet + popup.padding
                    // Skip the strip overlapping the bar (at the bottom when upward).
                    y: popup.padding + (popup.upward ? 0 : popup.overlap)
                    width: popup.cardWidth - popup.padding * 2
                    spacing: 4
                }
            }
        }
    ]
}
