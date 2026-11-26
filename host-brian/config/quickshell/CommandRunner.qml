// One-shot command runner that logs stderr output.
import QtQuick
import Quickshell.Io

Process {
    id: proc

    property string name: "Command"

    function run(cmd) {
        if (running)
            return

        command = cmd
        running = true
    }

    stderr: StdioCollector {
        onStreamFinished: {
            const message = text.trim()
            if (message.length > 0)
                console.warn(proc.name + " failed:", message)
        }
    }
}
