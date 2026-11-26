// Mutually exclusive set of systemd user services matching one unit pattern.
// Instantiate once and share between indicators.
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property string title: servicePattern
    required property string servicePattern
    property var serviceOptions: []     // [{ name, label }]
    property int pollInterval: 5000

    property string activeService: ""
    readonly property bool active: activeService.length > 0
    readonly property bool busy: actionProc.running
    property bool refreshQueued: false

    function serviceLabel(service) {
        const option = serviceOptions.find(o => o.name === service)
        return option ? option.label : service
    }

    function refreshStatus() {
        if (statusProc.running)
            refreshQueued = true
        else
            statusProc.running = true
    }

    function switchTo(service) {
        if (busy || service === activeService)
            return

        // Stop the running variant first; only start the new one if that worked.
        actionProc.command = active
            ? ["sh", "-c", "systemctl --user stop \"$1\" && systemctl --user start \"$2\"",
               "sh", servicePattern, service]
            : ["systemctl", "--user", "start", service]
        actionProc.running = true
    }

    function stopServices() {
        if (busy || !active)
            return

        actionProc.command = ["systemctl", "--user", "stop", servicePattern]
        actionProc.running = true
    }

    Process {
        id: statusProc
        command: [
            "systemctl", "--user", "list-units", "--state=active",
            "--plain", "--no-legend", "--no-pager", root.servicePattern
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const units = text.trim().split("\n").map(l => l.trim().split(/\s+/)[0])
                const match = units.find(u => root.serviceOptions.some(o => o.name === u))
                root.activeService = match ?? ""
            }
        }
        onRunningChanged: {
            if (!running && root.refreshQueued) {
                root.refreshQueued = false
                running = true
            }
        }
    }

    CommandRunner {
        id: actionProc
        name: "Service action"
        onRunningChanged: {
            if (!running)
                root.refreshStatus()
        }
    }

    Timer {
        interval: root.pollInterval
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refreshStatus()
    }
}
