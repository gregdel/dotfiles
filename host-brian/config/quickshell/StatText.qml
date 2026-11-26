// Bar readout text; monospace so padded numbers keep a fixed width.
import QtQuick

Text {
    color: Appearance.textColor
    font.family: Appearance.barFontFamily
    font.pixelSize: Appearance.barStatFontSize

    Behavior on color { ColorAnimation { duration: Appearance.meterDuration } }
}
