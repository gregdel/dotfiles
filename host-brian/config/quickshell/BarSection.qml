// Hoverable bar segment: children are laid out in a vertically centred row.
// Informational sections open their popup after a short hover; `clickable`
// ones (menus, controls) show a hand cursor and open only on click.
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property BarPopup popup: null
    property bool clickable: false
    property alias spacing: row.spacing
    default property alias content: row.data

    signal clicked(var mouse)
    signal scrolled(var wheel)

    implicitWidth: row.implicitWidth + 20
    implicitHeight: Appearance.barHeight

    onPopupChanged: {
        if (!popup)
            return
        popup.anchorItem = root
        popup.anchorHovered = Qt.binding(() => mouse.containsMouse)
    }

    data: [
        Rectangle {
            anchors {
                fill: parent
                topMargin: 4
                bottomMargin: 4
                leftMargin: 3
                rightMargin: 3
            }
            radius: 6
            color: mouse.containsMouse || (root.popup && root.popup.opened)
                ? Appearance.hoverBackground : "transparent"

            Behavior on color { ColorAnimation { duration: Appearance.hoverDuration } }
        },

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 8
        },

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onEntered: {
                if (!root.clickable)
                    openTimer.restart()
            }
            onExited: openTimer.stop()
            onClicked: mouse => {
                openTimer.stop()
                if (root.popup)
                    root.popup.toggle()
                root.clicked(mouse)
            }
            onWheel: wheel => root.scrolled(wheel)
        },

        Timer {
            id: openTimer
            interval: 300
            onTriggered: {
                if (root.popup)
                    root.popup.open()
            }
        }
    ]
}
