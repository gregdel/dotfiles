pragma Singleton

// System telemetry from the `sysinfo` script, polled once and shared.
// Rates (CPU load, network) are derived from cumulative counters between
// samples; histories keep the last `historySize` samples for graphs.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int interval: 2000
    readonly property int historySize: 60

    // Latest values; -1 means unknown.
    property real cpuLoad: -1
    property var coreLoads: []
    property int cpuTemp: -1
    property string cpuModel: ""

    property real gpuLoad: -1
    property int gpuEdge: -1
    property int gpuJunction: -1
    property int gpuMemTemp: -1
    property real gpuPower: -1
    property real gpuPowerCap: -1
    property int gpuCoreClock: -1
    property int gpuMemClock: -1
    property int fanRpm: -1
    property int fanPct: -1

    property real vramUsed: -1      // MiB
    property real vramTotal: -1
    property real memUsed: -1       // MiB
    property real memTotal: -1
    property real swapUsed: -1
    property real swapTotal: -1

    property string netIface: ""
    property real netRx: -1         // bytes/s
    property real netTx: -1

    property var cpuHistory: []
    property var cpuTempHistory: []
    property var gpuHistory: []
    property var gpuTempHistory: []
    property var netRxHistory: []
    property var netTxHistory: []

    property var topMemory: []      // [{ name, mib }], see refreshTopMemory()

    // Heat level: -1 unknown, 0 normal, 1 warm, 2 hot.
    readonly property int cpuHeat: heat(cpuTemp, 80, 90)
    readonly property int gpuHeat: heat(gpuJunction, 90, 100)
    readonly property real memFraction: memTotal > 0 ? memUsed / memTotal : -1
    readonly property real vramFraction: vramTotal > 0 ? vramUsed / vramTotal : -1

    property var prevCpu: null
    property var prevNet: null

    function heat(temp, warm, hot) {
        if (temp < 0) return -1
        return temp >= hot ? 2 : temp >= warm ? 1 : 0
    }

    function heatColor(level, normal) {
        if (level === 2) return Appearance.dangerColor
        if (level === 1) return Appearance.accentColor
        if (level < 0) return Appearance.inactiveColor
        return normal
    }

    // Fill level colour for meters: tinted only when nearly full.
    function fillColor(fraction, normal) {
        if (fraction >= 0.9) return Appearance.dangerColor
        if (fraction >= 0.75) return Appearance.accentColor
        return normal
    }

    function pad(value, width) {
        return String(value).padStart(width, " ")
    }

    function percent(v) {
        return v < 0 ? " --%" : pad(Math.round(v), 3) + "%"
    }

    function degrees(v) {
        return v < 0 ? "--°" : pad(v, 2) + "°"
    }

    function watts(v) {
        return v < 0 ? " --W" : pad(Math.round(v), 3) + "W"
    }

    function gib(mib) {
        return mib < 0 ? "--" : (mib / 1024).toFixed(1)
    }

    // Fixed five-character byte rate, e.g. " 512B", " 1.2K", "  34M".
    function rate(bytesPerSecond) {
        if (bytesPerSecond < 0) return "  --"
        const units = ["B", "K", "M", "G"]
        let v = bytesPerSecond
        let i = 0
        while (v >= 1000 && i < units.length - 1) {
            v /= 1024
            i++
        }
        const shown = i === 0 || v >= 10 ? Math.round(v) : v.toFixed(1)
        return pad(shown, 4) + units[i]
    }

    function push(list, value) {
        const next = list.concat([value])
        return next.length > historySize ? next.slice(next.length - historySize) : next
    }

    function num(v) {
        return v === null || v === undefined ? -1 : v
    }

    function update(o) {
        const now = Date.now()

        if (o.cpu_stat && o.cpu_stat.length > 0) {
            if (prevCpu && prevCpu.length === o.cpu_stat.length) {
                const loads = o.cpu_stat.map((s, i) => {
                    const total = s[0] - prevCpu[i][0]
                    const idle = s[1] - prevCpu[i][1]
                    return total > 0 ? Math.max(0, Math.min(100, 100 * (1 - idle / total))) : 0
                })
                cpuLoad = loads[0]
                coreLoads = loads.slice(1)
            }
            prevCpu = o.cpu_stat
        }

        cpuTemp = num(o.cpu)
        gpuLoad = num(o.gpu_busy)
        gpuEdge = num(o.edge)
        gpuJunction = num(o.junc)
        gpuMemTemp = num(o.mem)
        gpuPower = num(o.power)
        gpuPowerCap = num(o.power_cap)
        gpuCoreClock = num(o.sclk)
        gpuMemClock = num(o.mclk)
        fanRpm = num(o.fan_rpm)
        fanPct = num(o.fan)
        vramUsed = num(o.vram)
        vramTotal = num(o.vram_total)

        const m = o.meminfo || {}
        memTotal = num(m.MemTotal)
        memUsed = m.MemTotal !== undefined && m.MemAvailable !== undefined
            ? m.MemTotal - m.MemAvailable : -1
        swapTotal = num(m.SwapTotal)
        swapUsed = m.SwapTotal !== undefined && m.SwapFree !== undefined
            ? m.SwapTotal - m.SwapFree : -1

        const iface = o.net_iface || ""
        if (iface !== "" && o.net_rx !== null && o.net_tx !== null) {
            if (prevNet && prevNet.iface === iface && now > prevNet.time) {
                const seconds = (now - prevNet.time) / 1000
                netRx = Math.max(0, (o.net_rx - prevNet.rx) / seconds)
                netTx = Math.max(0, (o.net_tx - prevNet.tx) / seconds)
            }
            prevNet = { iface: iface, rx: o.net_rx, tx: o.net_tx, time: now }
        } else {
            prevNet = null
            netRx = -1
            netTx = -1
        }
        netIface = iface

        if (cpuLoad >= 0) {
            cpuHistory = push(cpuHistory, cpuLoad)
            cpuTempHistory = push(cpuTempHistory, Math.max(0, cpuTemp))
        }
        if (gpuLoad >= 0) {
            gpuHistory = push(gpuHistory, gpuLoad)
            gpuTempHistory = push(gpuTempHistory, Math.max(0, gpuJunction))
        }
        if (netRx >= 0) {
            netRxHistory = push(netRxHistory, netRx)
            netTxHistory = push(netTxHistory, netTx)
        }
    }

    // Largest memory users, summed per command name. Called by popups while open.
    function refreshTopMemory() {
        if (!topMemoryProc.running)
            topMemoryProc.running = true
    }

    Process {
        id: sysinfoProc
        command: ["sysinfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()
                if (output.length === 0)
                    return

                let o
                try { o = JSON.parse(output) } catch (err) { return }
                root.update(o)
            }
        }
    }

    Timer {
        interval: root.interval
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!sysinfoProc.running)
                sysinfoProc.running = true
        }
    }

    Process {
        id: topMemoryProc
        command: ["sh", "-c",
            "ps -eo rss=,comm= | awk '{ rss = $1; sub(/^ *[0-9]+ +/, \"\"); sum[$0] += rss }"
            + " END { for (n in sum) printf \"%d\\t%s\\n\", sum[n] / 1024, n }' | sort -rn | head -n 5"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.topMemory = text.trim().split("\n")
                    .map(line => line.split("\t"))
                    .filter(f => f.length === 2)
                    .map(f => ({ mib: parseInt(f[0]), name: f[1] }))
            }
        }
    }

    Process {
        command: ["sh", "-c", "sed -n 's/^model name[[:space:]]*: //p' /proc/cpuinfo | head -n 1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.cpuModel = text.trim()
                    .replace(/^AMD\s+|^Intel\(R\)\s+Core\(TM\)\s+/, "")
                    .replace(/\s+\d+-Core Processor$/, "")
            }
        }
    }
}
