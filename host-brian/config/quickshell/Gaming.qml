import QtQuick
import Quickshell
import Quickshell.Io

Item {
    property string ps4Text: "󰖻"
    property string steamText: ""
    property double steamLastSuccess: 0
    property int steamStaleAfter: 60000
    property string displayText: {
        const controllers = []
        if (ps4Text.length > 0 && ps4Text !== "󰖻")
            controllers.push(ps4Text)
        if (steamText.length > 0)
            controllers.push(steamText)
        return controllers.length > 0 ? controllers.join(" / ") : "󰖻"
    }

    implicitWidth: gamingLabel.implicitWidth + 20
    implicitHeight: 30

    property bool disconnected: displayText === "󰖻"

    function formatSteamControllers(output) {
        const controllers = []
        const lines = output.trim().split(/\r?\n/)

        for (const line of lines) {
            const fields = line.trim().split(/\s+/)
            if (fields.length < 2)
                continue

            const battery = fields[fields.length - 1].replace(/%$/, "")
            if (/^\d+$/.test(battery))
                controllers.push("󰊴 " + battery + "%")
        }

        return controllers.join(" / ")
    }

    Text {
        id: gamingLabel
        anchors.centerIn: parent
        color: parent.disconnected ? "#505050" : "#d0d0d0"
        font.family: "monospace"
        font.pixelSize: 14
        text: parent.displayText
    }

    Process {
        id: ps4Controller
        command: ["ps4-controller"]
        stdout: StdioCollector {
            id: ps4Output
            onStreamFinished: {
                const output = text.trim()
                ps4Text = output.length > 0 ? output : "󰖻"
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!ps4Controller.running)
                ps4Controller.running = true
        }
    }

    Process {
        id: steamController
        command: ["scbat"]
        stdout: StdioCollector {
            id: steamOutput
            onStreamFinished: {
                const output = formatSteamControllers(text)
                if (output.length > 0) {
                    steamText = output
                    steamLastSuccess = Date.now()
                }
            }
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!steamController.running)
                steamController.running = true
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            if (steamText.length > 0
                    && !steamController.running
                    && Date.now() - steamLastSuccess >= steamStaleAfter) {
                steamText = ""
            }
        }
    }
}
