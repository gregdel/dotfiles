// llama.cpp server status from the node_exporter textfile that the
// llama-metrics timer rewrites every 10 s while the service runs.
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BarSection {
    id: root

    required property SystemdServiceGroup group

    readonly property int historySize: 30   // 5 minutes of 10 s samples
    readonly property string backend: group.active ? group.serviceLabel(group.activeService) : ""

    property string model: ""
    property bool routerUp: false
    property int processing: 0
    property int deferred: 0
    property real genRate: -1           // tokens/s while generating
    property real promptRate: -1
    property real contextTokens: -1
    property real draftAcceptance: -1   // % of drafted tokens accepted
    property var rateHistory: []

    property var prev: null
    property string lastText: ""

    readonly property bool generating: processing > 0
    readonly property real graphMax: Math.max(10, ...rateHistory) * 1.15

    function tokens(n) {
        return n < 0 ? "--" : n >= 1000 ? (n / 1000).toFixed(1) + "k" : String(Math.round(n))
    }

    function speed(v) {
        return v < 0 ? "--" : (v >= 100 ? Math.round(v) : v.toFixed(1)) + " t/s"
    }

    function reset() {
        model = ""
        routerUp = false
        processing = 0
        deferred = 0
        genRate = -1
        promptRate = -1
        contextTokens = -1
        draftAcceptance = -1
        rateHistory = []
        prev = null
        lastText = ""
    }

    function parse(text) {
        // Reloads are faster than the 10 s writes; skip unchanged snapshots.
        if (text === lastText)
            return
        lastText = text

        const m = {}
        let loadedModel = ""
        for (const line of text.split("\n")) {
            const r = /^(\w+)\{([^}]*)\}\s+(\S+)/.exec(line)
            if (!r)
                continue
            if (r[1] === "llama_model_info") {
                const label = /model="((?:[^"\\]|\\.)*)"/.exec(r[2])
                if (label)
                    loadedModel = label[1]
            } else {
                m[r[1]] = parseFloat(r[3])
            }
        }

        routerUp = m.llama_router_up === 1
        model = loadedModel
        processing = m.llama_requests_processing ?? 0
        deferred = m.llama_requests_deferred ?? 0
        contextTokens = m.llama_kv_cache_tokens ?? -1

        const drafted = m.llama_spec_draft_tokens_total ?? 0
        draftAcceptance = drafted > 0 ? 100 * (m.llama_spec_accepted_tokens_total ?? 0) / drafted : -1

        // Rates from cumulative counters; the upstream gauges often read zero.
        const cur = {
            model: loadedModel,
            tokens: m.llama_generated_tokens_total,
            seconds: m.llama_generation_seconds_total,
            promptTokens: m.llama_prompt_tokens_total,
            promptSeconds: m.llama_prompt_seconds_total
        }
        let sample = 0
        if (prev && prev.model === cur.model) {
            if (cur.seconds > prev.seconds) {
                genRate = (cur.tokens - prev.tokens) / (cur.seconds - prev.seconds)
                sample = genRate
            }
            if (cur.promptSeconds > prev.promptSeconds)
                promptRate = (cur.promptTokens - prev.promptTokens) / (cur.promptSeconds - prev.promptSeconds)
        }
        prev = cur

        if (loadedModel !== "") {
            const next = rateHistory.concat([sample])
            rateHistory = next.length > historySize ? next.slice(next.length - historySize) : next
        }
    }

    Connections {
        target: root.group
        function onActiveChanged() {
            if (!root.group.active)
                root.reset()
        }
    }

    FileView {
        id: prom
        path: root.group.active ? "/var/lib/node_exporter/llama.prom" : ""
        printErrors: false
        onLoaded: root.parse(text())
        onLoadFailed: root.routerUp = false
    }

    Timer {
        interval: 5000
        repeat: true
        running: root.group.active
        onTriggered: prom.reload()
    }

    StatText {
        text: ""
        font.pixelSize: Appearance.barFontSize
        color: root.generating ? Appearance.accentColor
            : root.model !== "" ? Appearance.textDim
            : Appearance.textFaint
    }

    StatText {
        Layout.maximumWidth: 180
        elide: Text.ElideRight
        text: root.model !== "" ? root.model
            : root.routerUp ? "no model loaded"
            : "starting…"
        color: root.model !== "" ? Appearance.textColor : Appearance.textFaint
    }

    Sparkline {
        visible: root.model !== ""
        implicitWidth: 48
        capacity: root.historySize
        values: root.rateHistory
        maxValue: root.graphMax
        color: root.generating ? Appearance.accentColor : Appearance.graphColor
    }

    StatText {
        visible: root.model !== ""
        text: Stats.pad(root.generating ? root.speed(root.genRate) : "idle", 8)
        color: root.generating ? Appearance.textColor : Appearance.textFaint
    }

    popup: BarPopup {
        cardWidth: 300
        spacing: 10

        PopupHeading {
            title: "llama.cpp"
            detail: root.backend
        }

        PopupStat {
            width: parent.width
            label: "Model"
            value: root.model !== "" ? root.model : root.routerUp ? "none loaded" : "starting…"
            valueColor: root.model !== "" ? Appearance.textColor : Appearance.textDim
        }

        Sparkline {
            width: parent.width
            height: 56
            grid: true
            capacity: root.historySize
            values: root.rateHistory
            maxValue: root.graphMax
            color: Appearance.accentColor
            fillOpacity: 0.2
        }

        Grid {
            width: parent.width
            columns: 2
            columnSpacing: 16

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Generate"
                value: root.speed(root.genRate)
                swatch: Appearance.accentColor
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Prompt"
                value: root.speed(root.promptRate)
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Requests"
                value: root.deferred > 0 ? root.processing + " +" + root.deferred : String(root.processing)
                valueColor: root.generating ? Appearance.textColor : Appearance.textDim
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                label: "Context"
                value: root.tokens(root.contextTokens)
            }

            PopupStat {
                width: (parent.width - parent.columnSpacing) / 2
                visible: root.draftAcceptance >= 0
                label: "Draft hit"
                value: Math.round(root.draftAcceptance) + "%"
            }
        }
    }
}
