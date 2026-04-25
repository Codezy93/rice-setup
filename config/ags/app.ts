// AGS v2 entry — bootstraps panel windows that mirror preview-new
// (Sidebar, RightPanel, MissionTimeline). Toggle from Hyprland with
//     ags toggle <name>
//
// Layout (matches React preview):
//     ┌───────────────────────────────────────────────────────────┐
//     │                       Waybar (top)                        │
//     ├──────────┬────────────────────────────────────┬───────────┤
//     │          │                                    │           │
//     │ Sidebar  │           (windows tile)           │ RightPnl  │
//     │          │                                    │           │
//     ├──────────┴────────────────────────────────────┴───────────┤
//     │                  Mission Timeline (bottom)                │
//     └───────────────────────────────────────────────────────────┘

import { App } from "astal/gtk3"
import style from "./style.css"

import Sidebar          from "./widgets/Sidebar"
import RightPanel       from "./widgets/RightPanel"
import MissionTimeline  from "./widgets/MissionTimeline"

App.start({
    css: style,
    main() {
        Sidebar()
        RightPanel()
        MissionTimeline()
    },
})
