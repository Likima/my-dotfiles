import app from "ags/gtk3/app"
import { Astal, Gtk, Gdk } from "ags/gtk3"
import { exec, execAsync } from "ags/process"
import { createPoll } from "ags/time"
import { createState } from "ags"
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

// System info polling
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

const uptime = createPoll("0h", 60000, () => {
    try {
        const result = exec(["bash", "-c", "uptime -p | sed 's/up //'"])
        return result.trim()
    } catch { return "0h" }
})

const activeWorkspace = createPoll("1", 500, () => {
    try {
        const result = exec(["hyprctl", "activeworkspace", "-j"])
        const ws = JSON.parse(result)
        return String(ws.id || 1)
    } catch { return "1" }
})

// Polled values for media
const title = createPoll("Not Playing", 1000, () => getPlayerctl("title") || "Not Playing")
const artist = createPoll("Unknown Artist", 1000, () => getPlayerctl("artist") || "Unknown Artist")
const album = createPoll("Unknown Album", 1000, () => getPlayerctl("album") || "Unknown Album")
const artUrl = createPoll("", 1000, () => getArtUrl())
const status = createPoll("Stopped", 1000, () => getStatus())
const position = createPoll(0, 1000, () => getPosition())
const duration = createPoll(0, 1000, () => getDuration())

// Dashboard Tab
function DashboardTab() {
    const date = createPoll("", 1000, "date '+%A, %B %d'")
    const time = createPoll("", 1000, "date '+%H:%M'")

    return (
        <box class="dashboard-content" vertical>
            <box class="datetime-box" vertical halign={Gtk.Align.CENTER}>
                <label class="time-display" label={time} />
                <label class="date-display" label={date} />
            </box>
            <box class="quick-stats" halign={Gtk.Align.CENTER}>
                <box class="stat-box" vertical>
                    <label class="stat-icon" label="󰍛" />
                    <label class="stat-value" label={memUsage} />
                    <label class="stat-label" label="Memory" />
                </box>
                <box class="stat-box" vertical>
                    <label class="stat-icon" label="󰋊" />
                    <label class="stat-value" label={diskUsage} />
                    <label class="stat-label" label="Disk" />
                </box>
                <box class="stat-box" vertical>
                    <label class="stat-icon" label="󰔟" />
                    <label class="stat-value" label={uptime} />
                    <label class="stat-label" label="Uptime" />
                </box>
            </box>
        </box>
    )
}

// Media Tab
function MediaTab() {
    return (
        <box class="media-content" vertical>
            <box class="media-header">
                <box
                    class="album-art"
                    css={artUrl((url: string) => url ? `background-image: url("file://${url}");` : "")}
                />
                <box class="track-info" vertical valign={Gtk.Align.CENTER}>
                    <label class="track-title" label={title} halign={Gtk.Align.START} truncate />
                    <label class="track-album" label={album} halign={Gtk.Align.START} truncate />
                    <label class="track-artist" label={artist} halign={Gtk.Align.START} truncate />
                </box>
            </box>

            <box class="controls" halign={Gtk.Align.CENTER}>
                <button
                    class="control-button"
                    onClicked={() => execAsync(["playerctl", "-p", "spotify", "previous"])}
                >
                    <label label="󰒮" />
                </button>
                <button
                    class="control-button play-pause"
                    onClicked={() => execAsync(["playerctl", "-p", "spotify", "play-pause"])}
                >
                    <label label={status((s: string) => s === "Playing" ? "󰏤" : "󰐊")} />
                </button>
                <button
                    class="control-button"
                    onClicked={() => execAsync(["playerctl", "-p", "spotify", "next"])}
                >
                    <label label="󰒭" />
                </button>
            </box>

            <box class="progress-container" vertical>
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
                    <label class="time" label={position(formatTime)} halign={Gtk.Align.START} hexpand />
                    <label class="time" label={duration(formatTime)} halign={Gtk.Align.END} />
                </box>
            </box>

            <box class="player-source" halign={Gtk.Align.CENTER}>
                <label class="source-icon" label="" />
                <label class="source-name" label="Spotify" />
            </box>
        </box>
    )
}

// Performance Tab
function PerformanceTab() {
    return (
        <box class="performance-content" vertical>
            <box class="perf-row">
                <box class="perf-item" vertical hexpand>
                    <box class="perf-header">
                        <label class="perf-icon cpu" label="󰻠" />
                        <label class="perf-title" label="CPU" />
                        <box hexpand />
                        <label class="perf-value" label={cpuUsage} />
                    </box>
                    <box class="perf-bar">
                        <box class="perf-fill cpu" css={cpuUsage((v: string) => `min-width: ${parseInt(v)}px;`)} />
                    </box>
                </box>
            </box>
            <box class="perf-row">
                <box class="perf-item" vertical hexpand>
                    <box class="perf-header">
                        <label class="perf-icon mem" label="󰍛" />
                        <label class="perf-title" label="Memory" />
                        <box hexpand />
                        <label class="perf-value" label={memUsage} />
                    </box>
                    <box class="perf-bar">
                        <box class="perf-fill mem" css={memUsage((v: string) => `min-width: ${parseInt(v)}px;`)} />
                    </box>
                </box>
            </box>
            <box class="perf-row">
                <box class="perf-item" vertical hexpand>
                    <box class="perf-header">
                        <label class="perf-icon disk" label="󰋊" />
                        <label class="perf-title" label="Disk" />
                        <box hexpand />
                        <label class="perf-value" label={diskUsage} />
                    </box>
                    <box class="perf-bar">
                        <box class="perf-fill disk" css={diskUsage((v: string) => `min-width: ${parseInt(v)}px;`)} />
                    </box>
                </box>
            </box>
        </box>
    )
}

// Workspaces Tab
function WorkspacesTab() {
    const workspaces = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    return (
        <box class="workspaces-content" vertical>
            <label class="workspaces-title" label="Workspaces" halign={Gtk.Align.START} />
            <box class="workspaces-grid" halign={Gtk.Align.CENTER}>
                {workspaces.map(ws => (
                    <button
                        class={activeWorkspace((active: string) =>
                            `workspace-button ${active === String(ws) ? 'active' : ''}`
                        )}
                        onClicked={() => execAsync(["hyprctl", "dispatch", "workspace", String(ws)])}
                    >
                        <label label={String(ws)} />
                    </button>
                ))}
            </box>
            <box class="workspace-info" vertical halign={Gtk.Align.CENTER}>
                <label class="workspace-current" label={activeWorkspace((ws: string) => `Current: ${ws}`)} />
            </box>
        </box>
    )
}

function MediaPopup() {
    const [activeTab, setActiveTab] = createState("media")

    function TabContent() {
        return (
            <box vertical class="content">
                <revealer
                    revealChild={activeTab((t: string) => t === 'dashboard')}
                    transitionType={Gtk.RevealerTransitionType.NONE}
                >
                    <DashboardTab />
                </revealer>
                <revealer
                    revealChild={activeTab((t: string) => t === 'media')}
                    transitionType={Gtk.RevealerTransitionType.NONE}
                >
                    <MediaTab />
                </revealer>
                <revealer
                    revealChild={activeTab((t: string) => t === 'performance')}
                    transitionType={Gtk.RevealerTransitionType.NONE}
                >
                    <PerformanceTab />
                </revealer>
                <revealer
                    revealChild={activeTab((t: string) => t === 'workspaces')}
                    transitionType={Gtk.RevealerTransitionType.NONE}
                >
                    <WorkspacesTab />
                </revealer>
            </box>
        )
    }

    return (
        <window
            name="media-popup"
            class="media-popup-window"
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
                <box hexpand vexpand valign={Gtk.Align.START} halign={Gtk.Align.CENTER}>
                    <eventbox
                        onButtonPressEvent={() => true}
                    >
                        <box vertical class="popup-container">
                            <box class="tab-bar">
                                <button
                                    class={activeTab((t: string) => `tab-button ${t === 'dashboard' ? 'active' : ''}`)}
                                    onClicked={() => setActiveTab("dashboard")}
                                >
                                    <box>
                                        <label class="tab-icon" label="󰕮" />
                                        <label label="Dashboard" />
                                    </box>
                                </button>
                                <button
                                    class={activeTab((t: string) => `tab-button ${t === 'media' ? 'active' : ''}`)}
                                    onClicked={() => setActiveTab("media")}
                                >
                                    <box>
                                        <label class="tab-icon" label="󰎈" />
                                        <label label="Media" />
                                    </box>
                                </button>
                                <button
                                    class={activeTab((t: string) => `tab-button ${t === 'performance' ? 'active' : ''}`)}
                                    onClicked={() => setActiveTab("performance")}
                                >
                                    <box>
                                        <label class="tab-icon" label="󰓅" />
                                        <label label="Performance" />
                                    </box>
                                </button>
                                <button
                                    class={activeTab((t: string) => `tab-button ${t === 'workspaces' ? 'active' : ''}`)}
                                    onClicked={() => setActiveTab("workspaces")}
                                >
                                    <box>
                                        <label class="tab-icon" label="󰕰" />
                                        <label label="Workspaces" />
                                    </box>
                                </button>
                            </box>

                            <TabContent />
                        </box>
                    </eventbox>
                </box>
            </eventbox>
        </window>
    )
}

app.start({
    css: style,
    instanceName: "media-popup",
    main() {
        MediaPopup()
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
