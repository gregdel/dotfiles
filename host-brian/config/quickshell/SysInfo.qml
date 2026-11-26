import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 0

    component Divider: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 18
        Layout.leftMargin: 2
        Layout.rightMargin: 2
        color: Appearance.barDivider
    }

    CpuSection {}
    Divider {}
    GpuSection {}
    Divider {}
    MemorySection {}
}
