// Sidebar — left rail (mirrors preview-new/src/components/Sidebar.jsx)

import { App, Astal, Gtk, Gdk } from "astal/gtk3"

type NavItem = { label: string; icon: string; active?: boolean }
type Section = { title: string; items: NavItem[] }

const SECTIONS: Section[] = [
    {
        title: "OVERVIEW",
        items: [
            { label: "Dashboard", icon: "view-grid-symbolic", active: true },
            { label: "Timeline",  icon: "appointment-soon-symbolic" },
        ],
    },
    {
        title: "OPERATIONS",
        items: [
            { label: "Squads",   icon: "security-high-symbolic" },
            { label: "Vehicles", icon: "find-location-symbolic" },
            { label: "Weapons",  icon: "weather-storm-symbolic" },
        ],
    },
    {
        title: "INTELLIGENCE",
        items: [
            { label: "Recon",    icon: "find-location-symbolic" },
            { label: "Signals",  icon: "network-wireless-symbolic" },
            { label: "Reports",  icon: "text-x-generic-symbolic" },
            { label: "Targets",  icon: "find-location-symbolic" },
        ],
    },
    {
        title: "SETTINGS",
        items: [
            { label: "Profile",     icon: "avatar-default-symbolic" },
            { label: "Preferences", icon: "preferences-system-symbolic" },
            { label: "Audit Log",   icon: "text-x-generic-symbolic" },
        ],
    },
]

const SERVICES = [
    { label: "podman", value: "12 ctn" },
    { label: "ufw",    value: "active" },
]

function NavRow(it: NavItem) {
    return <button
        className={`nav-item ${it.active ? "active" : ""}`}
    >
        <box spacing={8}>
            <icon icon={it.icon} />
            <label label={it.label} halign={Gtk.Align.START} hexpand />
        </box>
    </button>
}

function ServiceRow({ label, value }: { label: string; value: string }) {
    return <box className="service-row" spacing={8}>
        <box className="ok-dot" />
        <label label={label} hexpand halign={Gtk.Align.START} />
        <label label={value} halign={Gtk.Align.END} />
    </box>
}

export default function Sidebar() {
    return <window
        name="sidebar"
        application={App}
        anchor={Astal.WindowAnchor.LEFT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        keymode={Astal.Keymode.NONE}
        layer={Astal.Layer.TOP}
        margin-top={40}
        margin-bottom={170}
    >
        <box vertical className="sidebar glass" spacing={4}>
            {SECTIONS.map(s => (
                <box vertical>
                    <label className="section-label" label={s.title} halign={Gtk.Align.START} />
                    <box vertical spacing={2}>
                        {s.items.map(NavRow)}
                    </box>
                </box>
            ))}
            <box hexpand vexpand />
            <box vertical spacing={2}>
                {SERVICES.map(s => <ServiceRow {...s} />)}
            </box>
        </box>
    </window>
}
