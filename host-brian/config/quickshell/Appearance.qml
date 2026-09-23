pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property int barHeight: 40
    property string barFontFamily: "monospace"
    property int barFontSize: 18

    property int workspacePillHeight: 30
    property int workspaceMinPillWidth: 30
    property int workspaceHorizontalPadding: 14

    property color popupBackground: "#202020"
    property color popupBorder: "#303030"
    property int popupRadius: 8
}
