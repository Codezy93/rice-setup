-- Custom colorscheme built from the project palette.
-- Uses a modified tokyonight-night as the base (closest dark blue-black match)
-- and overrides specific highlights to match AGENT.md exactly.
return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style     = "night",
            transparent = false,
            terminal_colors = true,
            styles = {
                comments  = { italic = true },
                keywords  = { italic = false },
                functions = {},
                variables = {},
            },
            on_colors = function(c)
                -- Core surfaces (project palette)
                c.bg            = "#0B0F14"
                c.bg_dark       = "#0B0F14"
                c.bg_float      = "#121821"
                c.bg_highlight  = "#18212B"
                c.bg_popup      = "#121821"
                c.bg_sidebar    = "#121821"
                c.bg_statusline = "#121821"
                c.bg_visual     = "#3A8DFF33"
                c.border        = "#263241"

                -- Text
                c.fg            = "#E6EDF3"
                c.fg_dark       = "#9AA7B2"
                c.fg_gutter     = "#6B7785"
                c.comment       = "#6B7785"

                -- Accents
                c.blue          = "#3A8DFF"
                c.blue1         = "#3A8DFF"
                c.blue5         = "#22D3EE"
                c.cyan          = "#22D3EE"
                c.green         = "#22C55E"
                c.green1        = "#22C55E"
                c.orange        = "#F59E0B"
                c.red           = "#EF4444"
                c.red1          = "#EF4444"
                c.yellow        = "#F59E0B"
            end,
            on_highlights = function(hl, c)
                -- Cursor line — subtle surface lift
                hl.CursorLine     = { bg = "#121821" }
                hl.CursorLineNr   = { fg = c.blue, bold = true }

                -- Selection
                hl.Visual         = { bg = "#3A8DFF22" }

                -- Borders (splits, float frames)
                hl.WinSeparator   = { fg = c.border }
                hl.FloatBorder    = { fg = c.border, bg = c.bg_float }

                -- Telescope
                hl.TelescopeBorder        = { fg = c.border, bg = c.bg_float }
                hl.TelescopeNormal        = { bg = c.bg_float }
                hl.TelescopePromptNormal  = { bg = "#18212B" }
                hl.TelescopePromptBorder  = { fg = c.blue, bg = "#18212B" }
                hl.TelescopeSelectionCaret = { fg = c.blue }
                hl.TelescopeSelection     = { bg = "#18212B", fg = c.fg }

                -- nvim-tree
                hl.NvimTreeNormal         = { bg = "#0D1117" }
                hl.NvimTreeWinSeparator   = { fg = c.border }

                -- Diagnostics
                hl.DiagnosticUnderlineError = { undercurl = true, sp = c.red }
                hl.DiagnosticUnderlineWarn  = { undercurl = true, sp = c.orange }
                hl.DiagnosticUnderlineInfo  = { undercurl = true, sp = c.blue }
                hl.DiagnosticUnderlineHint  = { undercurl = true, sp = c.cyan }

                -- Git signs
                hl.GitSignsAdd     = { fg = c.green }
                hl.GitSignsChange  = { fg = c.orange }
                hl.GitSignsDelete  = { fg = c.red }
            end,
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd.colorscheme("tokyonight-night")
        end,
    },
}
