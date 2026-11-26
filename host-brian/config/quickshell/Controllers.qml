pragma Singleton

// Game controller battery state, polled once and shared by every bar.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string disconnectedIcon: "󰖻"
    property string ps4Text: ""
    property string steamText: ""
    property double steamLastSuccess: 0
    property int steamStaleAfter: 60000

    // Battery levels padded to three digits so the bar doesn't shift.
    readonly property string displayText: [ps4Text, steamText]
        .filter(t => t.length > 0)
        .join(" / ")
        .replace(/(\d+)%/g, (match, digits) => digits.padStart(3, " ") + "%")
    readonly property bool connected: displayText.length > 0

    function formatSteamControllers(output) {
        const controllers = []

        for (const line of output.trim().split(/\r?\n/)) {
            const fields = line.trim().split(/\s+/)
            if (fields.length < 2)
                continue

            const battery = fields[fields.length - 1].replace(/%$/, "")
            if (/^\d+$/.test(battery))
                controllers.push("󰊴 " + battery + "%")
        }

        return controllers.join(" / ")
    }

    Process {
        id: ps4Proc
        command: ["ps4-controller"]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()
                root.ps4Text = output === root.disconnectedIcon ? "" : output
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!ps4Proc.running)
                ps4Proc.running = true
        }
    }

    Process {
        id: steamProc
        command: ["scbat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = root.formatSteamControllers(text)
                if (output.length > 0) {
                    root.steamText = output
                    root.steamLastSuccess = Date.now()
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
            if (root.steamText.length > 0
                    && Date.now() - root.steamLastSuccess >= root.steamStaleAfter)
                root.steamText = ""

            if (!steamProc.running)
                steamProc.running = true
        }
    }
}
