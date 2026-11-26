pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property string fontFamily: "monospace"

    property int barHeight: 40
    property string barFontFamily: fontFamily
    property int barFontSize: 18
    property color barBackground: "#101010"
    property int barStatFontSize: 15
    property color barDivider: "#262626"
    // Line along the inner edge of the bar on the focused output; popups on
    // that bar continue it around themselves.
    property int focusLineWidth: 2
    property color focusLineColor: accentColor

    property int workspaceMinWidth: 30
    property int workspaceHorizontalPadding: 10

    // Popups share the bar's fill so they read as part of it.
    property color popupBackground: barBackground
    property color hoverBackground: "#1c1c1c"
    // Resting and hovered fill of prominent round buttons (e.g. play/pause).
    property color controlBackground: "#1e1e1e"
    property color controlHoverBackground: "#2a2a2a"
    property int popupRadius: 12
    property int popupFillet: 10

    property int popupOpenDuration: 250
    property int popupCloseDuration: 150
    property int hoverDuration: 100

    property color textColor: "#d0d0d0"
    property color textBright: "#e0e0e0"
    property color textDim: "#909090"
    property color textMuted: "#808080"
    property color textFaint: "#606060"
    property color inactiveColor: "#505050"
    property color accentColor: "#c4a000"
    property color dangerColor: "#cc6666"

    // Graphs and meters: neutral by default, tinted by heat/fill level.
    property color graphColor: "#8c8c8c"
    property color infoColor: "#66aaff"
    property color meterTrack: "#1e1e1e"
    property color gridColor: "#1a1a1a"
    property int meterDuration: 400
}
