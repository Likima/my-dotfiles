import app from "ags/gtk3/app"
import { Astal, Gtk, Gdk } from "ags/gtk3"
import { exec, execAsync } from "ags/process"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"
import style from "./style.scss"

const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor

function closePopup() {
    const popup = app.get_window("media-popup")
    if (popup) popup.hide()
}

function openPopup() {
    const popup = app.get_window("media-popup")
    if (popup) popup.show()
}

// --- Media helpers ---

function getArtUrl(): string {
    try {
        const url = exec(["playerctl", "-p", "spotify", "metadata", "mpris:artUrl"]).trim()
        if (!url) return ""

        let imageUrl = url
        if (url.includes("open.spotify.com")) {
            imageUrl = url.replace("open.spotify.com", "i.scdn.co")
        }

        const cacheDir = `${GLib.get_home_dir()}/.cache/ags`
        const artFile = `${cacheDir}/spotify_art.jpg`

        exec(["mkdir", "-p", cacheDir])
        exec(["curl", "-s", "-o", artFile, imageUrl])

        return artFile
    } catch {
        return ""
    }
}

function getPlayerctl(prop: string): string {
    try {
        return exec(["playerctl", "-p", "spotify", "metadata", prop]).trim()
    } catch {
        return ""
    }
}

function getStatus(): string {
    try {
        return exec(["playerctl", "-p", "spotify", "status"]).trim()
    } catch {
        return "Stopped"
    }
}

function getPosition(): number {
    try {
        return parseFloat(exec(["playerctl", "-p", "spotify", "position"])) || 0
    } catch {
        return 0
    }
}

function getDuration(): number {
    try {
        const dur = exec(["playerctl", "-p", "spotify", "metadata", "mpris:length"])
        return parseInt(dur) / 1000000 || 0
    } catch {
        return 0
    }
}

function formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins}:${secs.toString().padStart(2, '0')}`
}

// --- System info helper ---

function getSysInfo(): string {
    try {
        const user = exec(["whoami"]).trim()
        const host = exec(["hostname"]).trim()
        const os = exec(["bash", "-c", ". /etc/os-release && echo $PRETTY_NAME"]).trim()
        const kernel = exec(["uname", "-r"]).trim()
        const shell = exec(["bash", "-c", "basename $SHELL"]).trim()
        const pkgs = exec(["bash", "-c", "pacman -Qq 2>/dev/null | wc -l"]).trim()
        let res = "N/A"
        try {
            const monitors = exec(["hyprctl", "monitors", "-j"]).trim()
            const parsed = JSON.parse(monitors)
            if (parsed[0]) res = `${parsed[0].width}x${parsed[0].height}`
        } catch {}
        return `${user}@${host}|${os}|${kernel}|${shell}|${pkgs}|${res}`
    } catch { return "" }
}

function parseProcLine(data: string, index: number): { name: string, cpu: string, mem: string } {
    const lines = data.split("\n").filter(l => l.trim())
    if (index >= lines.length) return { name: "", cpu: "0.0", mem: "0.0" }
    const parts = lines[index].split("|")
    return { name: parts[0] || "", cpu: parts[1] || "0.0", mem: parts[2] || "0.0" }
}

// --- Polls: System ---

const cpuUsage = createPoll("0%", 2000, () => {
    try {
        const result = exec(["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"])
        return `${Math.round(parseFloat(result) || 0)}%`
    } catch { return "0%" }
})

const memUsage = createPoll("0%", 2000, () => {
    try {
        const result = exec(["bash", "-c", "free | grep Mem | awk '{printf \"%.0f\", $3/$2 * 100}'"])
        return `${result}%`
    } catch { return "0%" }
})

const diskUsage = createPoll("0%", 10000, () => {
    try {
        const result = exec(["bash", "-c", "df -h / | tail -1 | awk '{print $5}'"])
        return result.trim()
    } catch { return "0%" }
})

const cpuTemp = createPoll("", 3000, () => {
    try {
        const result = exec(["bash", "-c", "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null"]).trim()
        if (!result) return ""
        return `${Math.round(parseInt(result) / 1000)}°C`
    } catch { return "" }
})

const uptime = createPoll("", 60000, () => {
    try {
        return exec(["bash", "-c", "uptime -p | sed 's/up //'"]).trim()
    } catch { return "" }
})

const batteryLevel = createPoll("", 10000, () => {
    try {
        return exec(["bash", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null"]).trim()
    } catch { return "" }
})

const batteryStatus = createPoll("", 10000, () => {
    try {
        return exec(["bash", "-c", "cat /sys/class/power_supply/BAT0/status 2>/dev/null || cat /sys/class/power_supply/BAT1/status 2>/dev/null"]).trim()
    } catch { return "" }
})

const networkName = createPoll("", 5000, () => {
    try {
        const wifi = exec(["bash", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2"]).trim()
        if (wifi) return wifi
        const eth = exec(["bash", "-c", "nmcli -t -f TYPE,STATE dev 2>/dev/null | grep 'ethernet:connected'"]).trim()
        if (eth) return "Ethernet"
        return ""
    } catch { return "" }
})

const volumeLevel = createPoll("0", 1000, () => {
    try {
        const output = exec(["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]).trim()
        if (output.includes("MUTED")) return "muted"
        const parts = output.split(" ")
        return String(Math.round(parseFloat(parts[1]) * 100))
    } catch { return "0" }
})

const activeWorkspace = createPoll("1", 500, () => {
    try {
        const result = exec(["hyprctl", "activeworkspace", "-j"])
        const ws = JSON.parse(result)
        return String(ws.id || 1)
    } catch { return "1" }
})

// --- Polls: Media ---

const title = createPoll("Not Playing", 1000, () => getPlayerctl("title") || "Not Playing")
const artist = createPoll("", 1000, () => getPlayerctl("artist"))
const album = createPoll("", 1000, () => getPlayerctl("album"))
const artUrl = createPoll("", 2000, () => getArtUrl())
const status = createPoll("Stopped", 1000, () => getStatus())
const position = createPoll(0, 1000, () => getPosition())
const duration = createPoll(0, 1000, () => getDuration())

const date = createPoll("", 60000, "date '+%A, %B %d'")
const time = createPoll("", 1000, "date '+%H:%M'")

// --- Polls: Terminal & Processes ---

const sysInfoData = createPoll(getSysInfo(), 60000, getSysInfo)

const topProcs = createPoll("", 3000, () => {
    try {
        const raw = exec(["bash", "-c", "ps -eo comm,%cpu,%mem --sort=-%cpu | tail -n +2 | head -8"])
        return raw.trim().split("\n").map(line => {
            const parts = line.trim().split(/\s+/)
            return `${parts[0]}|${parts[1]}|${parts[2]}`
        }).join("\n")
    } catch { return "" }
})

// --- Widgets ---

function MediaWidget() {
    return (
        <box vertical class="tile" hexpand vexpand>
            <box class="widget-header">
                <label class="widget-header-icon media" label="󰎈" />
                <label class="widget-header-title" label="Now Playing" />
            </box>

            <box class="media-info">
                <box
                    class="album-art"
                    css={artUrl((url: string) => url ? `background-image: url("file://${url}");` : "")}
                />
                <box vertical class="track-info" valign={Gtk.Align.CENTER}>
                    <label class="track-title" label={title} halign={Gtk.Align.START} truncate />
                    <label class="track-artist" label={artist} halign={Gtk.Align.START} truncate />
                    <label class="track-album" label={album} halign={Gtk.Align.START} truncate />
                </box>
            </box>

            <box class="controls" halign={Gtk.Align.CENTER}>
                <button
                    class="control-btn"
                    onClicked={() => execAsync(["playerctl", "-p", "spotify", "previous"])}
                >
                    <label label="󰒮" />
                </button>
                <button
                    class="control-btn play-pause"
                    onClicked={() => execAsync(["playerctl", "-p", "spotify", "play-pause"])}
                >
                    <label label={status((s: string) => s === "Playing" ? "󰏤" : "󰐊")} />
                </button>
                <button
                    class="control-btn"
                    onClicked={() => execAsync(["playerctl", "-p", "spotify", "next"])}
                >
                    <label label="󰒭" />
                </button>
            </box>

            <box vertical class="progress-section">
                <slider
                    class="progress-slider"
                    value={position((pos: number) => {
                        const dur = duration.get()
                        return dur > 0 ? pos / dur : 0
                    })}
                    onDragged={(self) => {
                        const dur = duration.get()
                        if (dur > 0) {
                            execAsync(["playerctl", "-p", "spotify", "position", String(self.value * dur)])
                        }
                    }}
                />
                <box class="time-labels">
                    <label class="time-label" label={position(formatTime)} halign={Gtk.Align.START} hexpand />
                    <label class="time-label" label={duration(formatTime)} halign={Gtk.Align.END} />
                </box>
            </box>

            <box class="player-source" halign={Gtk.Align.CENTER}>
                <label class="source-icon" label="" />
                <label class="source-name" label="Spotify" />
            </box>
        </box>
    )
}

function PerformanceWidget() {
    return (
        <box vertical class="tile" hexpand vexpand>
            <box class="widget-header">
                <label class="widget-header-icon perf" label="󰓅" />
                <label class="widget-header-title" label="Performance" />
            </box>

            <box vertical class="perf-metrics">
                <box vertical class="metric">
                    <box class="metric-header">
                        <label class="metric-icon cpu" label="󰻠" />
                        <label class="metric-name" label="CPU" hexpand halign={Gtk.Align.START} />
                        <label class="metric-value" label={cpuUsage} />
                    </box>
                    <box class="metric-bar">
                        <box class="metric-fill cpu" css={cpuUsage((v: string) => `min-width: ${parseInt(v) * 2.5}px;`)} />
                    </box>
                </box>

                <box vertical class="metric">
                    <box class="metric-header">
                        <label class="metric-icon mem" label="󰍛" />
                        <label class="metric-name" label="Memory" hexpand halign={Gtk.Align.START} />
                        <label class="metric-value" label={memUsage} />
                    </box>
                    <box class="metric-bar">
                        <box class="metric-fill mem" css={memUsage((v: string) => `min-width: ${parseInt(v) * 2.5}px;`)} />
                    </box>
                </box>

                <box vertical class="metric">
                    <box class="metric-header">
                        <label class="metric-icon disk" label="󰋊" />
                        <label class="metric-name" label="Disk" hexpand halign={Gtk.Align.START} />
                        <label class="metric-value" label={diskUsage} />
                    </box>
                    <box class="metric-bar">
                        <box class="metric-fill disk" css={diskUsage((v: string) => `min-width: ${parseInt(v) * 2.5}px;`)} />
                    </box>
                </box>

                <box class="metric temp-row" visible={cpuTemp((v: string) => v !== "")}>
                    <label class="metric-icon temp" label="󰔐" />
                    <label class="metric-name" label="Temperature" hexpand halign={Gtk.Align.START} />
                    <label class="metric-value" label={cpuTemp} />
                </box>
            </box>
        </box>
    )
}

function SystemWidget() {
    return (
        <box vertical class="tile" hexpand vexpand>
            <box class="widget-header">
                <label class="widget-header-icon sys" label="󰕰" />
                <label class="widget-header-title" label="System" />
            </box>

            <box vertical class="sys-clock" halign={Gtk.Align.CENTER}>
                <label class="clock-time" label={time} />
                <label class="clock-date" label={date} />
            </box>

            <box vertical class="sys-workspaces">
                <label class="section-label" label="Workspaces" halign={Gtk.Align.START} />
                <box vertical halign={Gtk.Align.CENTER}>
                    <box halign={Gtk.Align.CENTER}>
                        {[1, 2, 3, 4, 5].map(ws => (
                            <button
                                class={activeWorkspace((active: string) =>
                                    `ws-btn ${active === String(ws) ? 'active' : ''}`
                                )}
                                onClicked={() => execAsync(["hyprctl", "dispatch", "workspace", String(ws)])}
                            >
                                <label label={String(ws)} />
                            </button>
                        ))}
                    </box>
                    <box halign={Gtk.Align.CENTER}>
                        {[6, 7, 8, 9, 10].map(ws => (
                            <button
                                class={activeWorkspace((active: string) =>
                                    `ws-btn ${active === String(ws) ? 'active' : ''}`
                                )}
                                onClicked={() => execAsync(["hyprctl", "dispatch", "workspace", String(ws)])}
                            >
                                <label label={String(ws)} />
                            </button>
                        ))}
                    </box>
                </box>
            </box>

            <box vertical class="sys-info">
                <box class="info-row" visible={batteryLevel((v: string) => v !== "")}>
                    <label class="info-icon" label={batteryStatus((s: string) =>
                        s === "Charging" ? "󰂄" : "󰁹"
                    )} />
                    <label class="info-label" label="Battery" hexpand halign={Gtk.Align.START} />
                    <label class="info-value" label={batteryLevel((v: string) => v ? `${v}%` : "")} halign={Gtk.Align.END} />
                </box>

                <box class="info-row">
                    <label class="info-icon" label={networkName((v: string) => v ? "󰤨" : "󰤭")} />
                    <label class="info-label" label="Network" hexpand halign={Gtk.Align.START} />
                    <label class="info-value" label={networkName((v: string) => v || "Disconnected")} halign={Gtk.Align.END} />
                </box>

                <box class="info-row">
                    <label class="info-icon" label={volumeLevel((v: string) => {
                        if (v === "muted") return "󰝟"
                        const n = parseInt(v)
                        if (n > 66) return "󰕾"
                        if (n > 33) return "󰖀"
                        return "󰕿"
                    })} />
                    <label class="info-label" label="Volume" hexpand halign={Gtk.Align.START} />
                    <label class="info-value" label={volumeLevel((v: string) => v === "muted" ? "Muted" : `${v}%`)} halign={Gtk.Align.END} />
                </box>

                <box class="info-row">
                    <label class="info-icon" label="󰔟" />
                    <label class="info-label" label="Uptime" hexpand halign={Gtk.Align.START} />
                    <label class="info-value" label={uptime} halign={Gtk.Align.END} />
                </box>
            </box>
        </box>
    )
}

function TerminalWidget() {
    return (
        <box vertical class="tile terminal-tile" hexpand>
            <box class="term-titlebar">
                <box class="term-dot red" />
                <box class="term-dot yellow" />
                <box class="term-dot green" />
                <label class="term-title" label="Terminal" />
            </box>

            <box vertical class="term-content">
                <label class="term-prompt" label="$ fastfetch" halign={Gtk.Align.START} />

                <label class="term-userhost" label={sysInfoData((d: string) =>
                    d.split("|")[0] || "user@host"
                )} halign={Gtk.Align.START} />

                <label class="term-separator" label={sysInfoData((d: string) => {
                    const uh = d.split("|")[0] || "user@host"
                    return "─".repeat(uh.length)
                })} halign={Gtk.Align.START} />

                <box class="term-info-row">
                    <label class="term-info-key" label="OS" halign={Gtk.Align.START} />
                    <label class="term-info-value" label={sysInfoData((d: string) => d.split("|")[1] || "")} halign={Gtk.Align.START} />
                </box>
                <box class="term-info-row">
                    <label class="term-info-key" label="Kernel" halign={Gtk.Align.START} />
                    <label class="term-info-value" label={sysInfoData((d: string) => d.split("|")[2] || "")} halign={Gtk.Align.START} />
                </box>
                <box class="term-info-row">
                    <label class="term-info-key" label="Shell" halign={Gtk.Align.START} />
                    <label class="term-info-value" label={sysInfoData((d: string) => d.split("|")[3] || "")} halign={Gtk.Align.START} />
                </box>
                <box class="term-info-row">
                    <label class="term-info-key" label="WM" halign={Gtk.Align.START} />
                    <label class="term-info-value" label="Hyprland" halign={Gtk.Align.START} />
                </box>
                <box class="term-info-row">
                    <label class="term-info-key" label="Pkgs" halign={Gtk.Align.START} />
                    <label class="term-info-value" label={sysInfoData((d: string) => {
                        const v = d.split("|")[4]
                        return v ? `${v} (pacman)` : ""
                    })} halign={Gtk.Align.START} />
                </box>
                <box class="term-info-row">
                    <label class="term-info-key" label="Uptime" halign={Gtk.Align.START} />
                    <label class="term-info-value" label={uptime} halign={Gtk.Align.START} />
                </box>
                <box class="term-info-row">
                    <label class="term-info-key" label="Res" halign={Gtk.Align.START} />
                    <label class="term-info-value" label={sysInfoData((d: string) => d.split("|")[5] || "")} halign={Gtk.Align.START} />
                </box>
                <box class="term-info-row">
                    <label class="term-info-key" label="Theme" halign={Gtk.Align.START} />
                    <label class="term-info-value" label="Tokyo Night" halign={Gtk.Align.START} />
                </box>
            </box>
        </box>
    )
}

function ProcessesWidget() {
    return (
        <box vertical class="tile" hexpand vexpand>
            <box class="widget-header">
                <label class="widget-header-icon proc" label="󰍹" />
                <label class="widget-header-title" label="Processes" />
            </box>

            <box class="proc-header-row">
                <label class="proc-header-label" label="PROCESS" hexpand halign={Gtk.Align.START} />
                <label class="proc-header-label proc-col" label="CPU%" halign={Gtk.Align.END} />
                <label class="proc-header-label proc-col" label="MEM%" halign={Gtk.Align.END} />
            </box>

            {[0, 1, 2, 3, 4, 5, 6, 7].map(i => (
                <box class="proc-row" visible={topProcs((d: string) => {
                    const lines = d.split("\n").filter(l => l.trim())
                    return i < lines.length
                })}>
                    <label
                        class="proc-name"
                        label={topProcs((d: string) => parseProcLine(d, i).name)}
                        hexpand
                        halign={Gtk.Align.START}
                        truncate
                    />
                    <label
                        class={topProcs((d: string) => {
                            const cpu = parseFloat(parseProcLine(d, i).cpu)
                            if (cpu > 20) return "proc-cpu proc-col high"
                            if (cpu > 5) return "proc-cpu proc-col mid"
                            return "proc-cpu proc-col low"
                        })}
                        label={topProcs((d: string) => `${parseProcLine(d, i).cpu}%`)}
                        halign={Gtk.Align.END}
                    />
                    <label
                        class="proc-mem proc-col"
                        label={topProcs((d: string) => `${parseProcLine(d, i).mem}%`)}
                        halign={Gtk.Align.END}
                    />
                </box>
            ))}
        </box>
    )
}

function ControlPanel() {
    return (
        <window
            name="media-popup"
            class="control-panel-window"
            visible={false}
            anchor={TOP | LEFT | RIGHT | BOTTOM}
            exclusivity={Astal.Exclusivity.IGNORE}
            keymode={Astal.Keymode.ON_DEMAND}
            layer={Astal.Layer.OVERLAY}
            onKeyPressEvent={(self, event: Gdk.EventKey) => {
                if (event.keyval === Gdk.KEY_Escape) {
                    closePopup()
                    return true
                }
                return false
            }}
            application={app}
        >
            <eventbox
                hexpand
                vexpand
                onButtonPressEvent={() => {
                    closePopup()
                    return true
                }}
            >
                <box vertical hexpand vexpand spacing={24} class="popup-container">
                    <box hexpand vexpand spacing={24}>
                        <eventbox onButtonPressEvent={() => true} vexpand>
                            <MediaWidget />
                        </eventbox>
                        <eventbox onButtonPressEvent={() => true} vexpand>
                            <PerformanceWidget />
                        </eventbox>
                        <eventbox onButtonPressEvent={() => true} vexpand>
                            <SystemWidget />
                        </eventbox>
                    </box>
                    <box hexpand vexpand spacing={24}>
                        <eventbox onButtonPressEvent={() => true} hexpand vexpand>
                            <ProcessesWidget />
                        </eventbox>
                    </box>
                </box>
            </eventbox>
        </window>
    )
}

app.start({
    css: style,
    instanceName: "media-popup",
    main() {
        ControlPanel()
    },
    requestHandler(request, res) {
        if (Array.isArray(request) && request[0] === "toggle") {
            const win = app.get_window("media-popup")
            if (win && win.visible) {
                closePopup()
            } else {
                openPopup()
            }
            res("toggled")
        } else {
            res("unknown command")
        }
    },
})
