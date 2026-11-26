// History graph: newest sample at the right edge, a soft gradient fill under
// the line and a dot on the latest value. Stack several for multiple series.
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property var values: []
    property int capacity: Stats.historySize
    property real minValue: 0
    property real maxValue: 100
    property color color: Appearance.graphColor
    property real lineWidth: 1.5
    property bool fill: true
    property real fillOpacity: 0.28
    property bool showDot: true
    property bool grid: false

    implicitWidth: 56
    implicitHeight: 20

    readonly property real dotRadius: 2
    // Keep the stroke and dot inside the item.
    readonly property real inset: Math.max(lineWidth, showDot ? dotRadius : 0)
    readonly property real step: capacity > 1 ? (width - inset * 2) / (capacity - 1) : 0

    readonly property var points: {
        const n = Math.min(values.length, capacity)
        const first = values.length - n
        const range = Math.max(1e-6, maxValue - minValue)
        const usable = height - inset * 2
        const right = width - inset
        const pts = []
        for (let i = 0; i < n; i++) {
            const v = Math.max(minValue, Math.min(maxValue, values[first + i]))
            pts.push(Qt.point(right - (n - 1 - i) * step,
                              inset + usable * (1 - (v - minValue) / range)))
        }
        return pts
    }

    readonly property var fillPoints: points.length < 2 ? [] : points.concat([
        Qt.point(points[points.length - 1].x, height),
        Qt.point(points[0].x, height)
    ])

    function withAlpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a)
    }

    Repeater {
        model: root.grid ? 3 : 0

        Rectangle {
            required property int index
            width: root.width
            height: 1
            y: Math.round(root.height * (index + 1) / 4)
            color: Appearance.gridColor
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: "transparent"
            fillGradient: LinearGradient {
                x1: 0; y1: 0
                x2: 0; y2: root.height
                GradientStop { position: 0; color: root.withAlpha(root.color, root.fill ? root.fillOpacity : 0) }
                GradientStop { position: 1; color: root.withAlpha(root.color, 0) }
            }
            PathPolyline { path: root.fill ? root.fillPoints : [] }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.color
            strokeWidth: root.lineWidth
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap
            PathPolyline { path: root.points.length > 1 ? root.points : [] }
        }
    }

    Rectangle {
        visible: root.showDot && root.points.length > 0
        readonly property point last: root.points.length > 0
            ? root.points[root.points.length - 1] : Qt.point(0, 0)
        x: last.x - width / 2
        y: last.y - height / 2
        width: root.dotRadius * 2
        height: width
        radius: width / 2
        color: root.color
    }
}
