// MissionTimeline — bottom strip: progress trackers · player · notifications
// Mirrors preview-new/src/components/MissionTimeline.jsx

import { App, Astal, Gtk } from "astal/gtk3"
import { Variable, bind } from "astal"
import Mpris from "gi://AstalMpris"

// ── Time-progress trackers ──────────────────────────────────────────────
function pctOfDay() {
    const d = new Date()
    return ((d.getHours()*3600 + d.getMinutes()*60 + d.getSeconds()) / 86400) * 100
}
function pctOfWeek() {
    const d = new Date()
    const day = (d.getDay() + 6) % 7
    return ((day*86400 + d.getHours()*3600 + d.getMinutes()*60) / (7*86400)) * 100
}
function pctOfMonth() {
    const d = new Date()
    const days = new Date(d.getFullYear(), d.getMonth()+1, 0).getDate()
    return ((d.getDate() - 1 + d.getHours()/24) / days) * 100
}
function pctOfYear() {
    const d = new Date()
    const start = new Date(d.getFullYear(), 0, 0)
    const total = (d.getFullYear() % 4 === 0) ? 366 : 365
    return (((d.getTime() - start.getTime()) / 86_400_000) / total) * 100
}

const trackers = Variable<{label: string, value: number}[]>([]).poll(60_000, () => [
    { label: "DAY",   value: pctOfDay()   },
    { label: "WEEK",  value: pctOfWeek()  },
    { label: "MONTH", value: pctOfMonth() },
    { label: "YEAR",  value: pctOfYear()  },
])

function ProgressTracker() {
    return <box vertical className="glass" hexpand spacing={8}>
        {trackers(list => <box vertical spacing={6}>
            {list.map(t => <box vertical>
                <box>
                    <label className="tracker-label" label={t.label} halign={Gtk.Align.START} hexpand />
                    <label className="tracker-value" label={`${t.value.toFixed(1)}%`} halign={Gtk.Align.END} />
                </box>
                <box className="perf-bar" hexpand>
                    <box className="perf-fill" css={`min-width: ${t.value}%;`} />
                </box>
            </box>)}
        </box>)}
    </box>
}

// ── Music player (MPRIS) ────────────────────────────────────────────────
function MusicPlayer() {
    const mpris  = Mpris.get_default()
    const player = mpris.get_players()[0]

    if (!player) {
        return <box className="glass" hexpand>
            <label label="No media" hexpand halign={Gtk.Align.CENTER} />
        </box>
    }

    return <box vertical className="glass" hexpand spacing={6}>
        <box spacing={8}>
            <icon icon="audio-x-generic-symbolic" />
            <box vertical hexpand>
                <label className="player-title" label={player.title || "—"}  halign={Gtk.Align.START} truncate />
                <label className="player-meta"  label={player.artist || "—"} halign={Gtk.Align.START} truncate />
            </box>
        </box>
        <box hexpand vexpand />
        <box spacing={20} halign={Gtk.Align.CENTER}>
            <button className="player-btn"  onClicked={() => player.previous()}><icon icon="media-skip-backward-symbolic" /></button>
            <button className="player-play" onClicked={() => player.play_pause()}>
                <icon icon={bind(player, "playbackStatus").as(s =>
                    s === Mpris.PlaybackStatus.PLAYING
                        ? "media-playback-pause-symbolic"
                        : "media-playback-start-symbolic")} />
            </button>
            <button className="player-btn" onClicked={() => player.next()}><icon icon="media-skip-forward-symbolic" /></button>
        </box>
    </box>
}

// ── Notifications (placeholder feed; AstalNotifd integration optional) ──
const NOTIFICATIONS = [
    { app: "System",  t: "now", text: "Updates available — 12 packages", icon: "system-software-update-symbolic" },
    { app: "Slack",   t: "2m",  text: "Ops sync moved to 10:00",         icon: "user-available-symbolic"          },
    { app: "Battery", t: "8m",  text: "Battery at 87% — discharging",    icon: "battery-good-symbolic"            },
    { app: "Mail",    t: "21m", text: "3 new messages",                  icon: "mail-unread-symbolic"             },
]

function Notifications() {
    return <box vertical className="glass" hexpand spacing={2}>
        {NOTIFICATIONS.map(n => (
            <box className="notif-row" spacing={8}>
                <icon icon={n.icon} />
                <box vertical hexpand>
                    <box>
                        <label className="notif-app"  label={n.app} halign={Gtk.Align.START} hexpand />
                        <label className="notif-time" label={n.t}   halign={Gtk.Align.END} />
                    </box>
                    <label className="notif-text" label={n.text} halign={Gtk.Align.START} truncate />
                </box>
            </box>
        ))}
    </box>
}

export default function MissionTimeline() {
    return <window
        name="mission-timeline"
        application={App}
        anchor={Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.BOTTOM}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        keymode={Astal.Keymode.NONE}
        layer={Astal.Layer.TOP}
    >
        <box className="mission-strip" spacing={8} css="min-height: 160px;">
            <ProgressTracker />
            <MusicPlayer />
            <Notifications />
        </box>
    </window>
}
