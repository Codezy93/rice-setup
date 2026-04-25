// RightPanel — system controls + status (mirrors RightPanel.jsx)

import { App, Astal, Gtk } from "astal/gtk3"
import { Variable, bind } from "astal"
import Network from "gi://AstalNetwork"
import Bluetooth from "gi://AstalBluetooth"

const QUOTE = "|| बलिदान परमो धर्मः ||"
const QUOTE_EN = "SACRIFICE IS THE HIGHEST DUTY"

function MissionStatus() {
    return <box className="glass-strong" spacing={12} css="padding: 14px;">
        <icon icon="emblem-favorite-symbolic" pixel-size={32} />
        <box vertical>
            <label className="quote" label={QUOTE} halign={Gtk.Align.START} />
            <label className="quote-en" label={QUOTE_EN} halign={Gtk.Align.START} />
        </box>
    </box>
}

function Slider({ icon, value, onChange }: {
    icon: string
    value: number
    onChange: (v: number) => void
}) {
    return <box spacing={10}>
        <icon icon={icon} />
        <slider
            hexpand
            value={value / 100}
            onDragged={({ value }) => onChange(Math.round(value * 100))}
        />
        <label label={`${value}`} css="min-width: 24px;" halign={Gtk.Align.END} />
    </box>
}

function ControlPanel() {
    const brightness = Variable(72)
    const volume     = Variable(45)
    const mic        = Variable(80)
    const muted      = Variable(false)

    return <box vertical className="glass" spacing={10}>
        {brightness(v => <Slider icon="display-brightness-symbolic"     value={v} onChange={x => brightness.set(x)} />)}
        {volume(v     => <Slider icon="audio-volume-high-symbolic"      value={v} onChange={x => volume.set(x)} />)}
        {mic(v        => <Slider icon="audio-input-microphone-symbolic" value={v} onChange={x => mic.set(x)} />)}
        <button
            className={muted(m => `btn ${m ? "muted" : ""}`)}
            hexpand
            onClicked={() => muted.set(!muted.get())}
        >
            <label label={muted(m => m ? "MUTED" : "MIC ON")} />
        </button>
    </box>
}

const PERF = [
    { label: "CPU",  icon: "utilities-system-monitor-symbolic", value: 32,  max: 100, unit: "%"  },
    { label: "MEM",  icon: "drive-harddisk-symbolic",           value: 6.4, max: 16,  unit: "GB" },
    { label: "GPU",  icon: "video-display-symbolic",            value: 18,  max: 100, unit: "%"  },
    { label: "DISK", icon: "drive-harddisk-symbolic",           value: 248, max: 512, unit: "GB" },
    { label: "TEMP", icon: "weather-clear-symbolic",            value: 54,  max: 100, unit: "°C" },
]

function Performance() {
    return <box vertical className="glass" spacing={6}>
        {PERF.map(p => {
            const pct  = (p.value / p.max) * 100
            const warn = p.label === "TEMP" && pct > 70
            return <box vertical>
                <box className="perf-row">
                    <icon icon={p.icon} />
                    <label label={` ${p.label}`} halign={Gtk.Align.START} hexpand />
                    <label label={`${p.value}${p.unit} / ${p.max}${p.unit}`} halign={Gtk.Align.END} />
                </box>
                <box className="perf-bar" hexpand>
                    <box className={`perf-fill ${warn ? "warn" : ""}`} css={`min-width: ${pct}%;`} />
                </box>
            </box>
        })}
    </box>
}

function ConnectionRow({ icon, label, status, on }: {
    icon: string; label: string; status: string; on: boolean
}) {
    return <box className="nav-item" spacing={10}>
        <icon icon={icon} />
        <box vertical hexpand>
            <label label={label} halign={Gtk.Align.START} />
            <label className="notif-text" label={status} halign={Gtk.Align.START} truncate />
        </box>
        <box
            className={on ? "toggle-on" : "toggle-off"}
            css="min-width: 22px; min-height: 12px; border-radius: 999px;"
        />
    </box>
}

function Connections() {
    const net = Network.get_default()
    const bt  = Bluetooth.get_default()

    const wifi = net?.wifi
    const wifiStatus = wifi
        ? bind(wifi, "ssid").as(s => s ?? "Disconnected")
        : Variable("Disconnected")()
    const wifiOn = wifi ? bind(wifi, "enabled") : Variable(false)()

    const btOn = bt ? bind(bt, "isPowered") : Variable(false)()

    return <box vertical className="glass" spacing={4}>
        {wifiStatus.as(s => <ConnectionRow
            icon="network-wireless-symbolic"
            label="Wi-Fi"
            status={s}
            on={true}
        />)}
        {btOn.as(on => <ConnectionRow
            icon="bluetooth-symbolic"
            label="Bluetooth"
            status={on ? "On" : "Off"}
            on={on}
        />)}
    </box>
}

function StatusGrid() {
    const cells = [
        { l: "UPDATES", v: "12 pending" },
        { l: "BATTERY", v: "87% · 4h12m" },
        { l: "UPTIME",  v: "2d 14h" },
        { l: "KERNEL",  v: "6.7-amd64" },
    ]
    const Cell = ({ l, v }: { l: string; v: string }) =>
        <box vertical className="kv" hexpand>
            <label className="kv-label" label={l} halign={Gtk.Align.START} />
            <label className="kv-value" label={v} halign={Gtk.Align.START} />
        </box>

    return <box vertical className="glass" spacing={8}>
        <box homogeneous spacing={6}><Cell {...cells[0]} /><Cell {...cells[1]} /></box>
        <box homogeneous spacing={6}><Cell {...cells[2]} /><Cell {...cells[3]} /></box>
        <box homogeneous spacing={4}>
            <button className="btn"        onClicked={() => Astal.exec("hyprlock")}><label label="LOCK"  /></button>
            <button className="btn"        onClicked={() => Astal.exec("systemctl suspend")}><label label="SLEEP" /></button>
            <button className="btn"        onClicked={() => Astal.exec("grim -g \"$(slurp)\" - | wl-copy")}><label label="SNAP" /></button>
            <button className="btn"><label label="PLANE" /></button>
            <button className="btn danger" onClicked={() => Astal.exec("systemctl poweroff")}><label label="PWR" /></button>
        </box>
    </box>
}

export default function RightPanel() {
    return <window
        name="right-panel"
        application={App}
        anchor={Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        keymode={Astal.Keymode.NONE}
        layer={Astal.Layer.TOP}
        margin-top={40}
        margin-bottom={170}
    >
        <box vertical className="right-panel" spacing={8}>
            <MissionStatus />
            <ControlPanel />
            <Performance />
            <Connections />
            <StatusGrid />
        </box>
    </window>
}
