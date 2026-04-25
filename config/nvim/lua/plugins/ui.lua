return {
    -- ── Status line ───────────────────────────────────────────────────────────
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = function()
            local palette = {
                bg      = "#0B0F14",
                surface = "#121821",
                border  = "#263241",
                blue    = "#3A8DFF",
                green   = "#22C55E",
                amber   = "#F59E0B",
                red     = "#EF4444",
                cyan    = "#22D3EE",
                text    = "#E6EDF3",
                muted   = "#6B7785",
            }
            local theme = {
                normal   = { a = { bg = palette.blue,  fg = palette.bg,  gui = "bold" },
                             b = { bg = palette.surface, fg = palette.text },
                             c = { bg = palette.bg,     fg = palette.muted } },
                insert   = { a = { bg = palette.green, fg = palette.bg,  gui = "bold" } },
                visual   = { a = { bg = palette.amber, fg = palette.bg,  gui = "bold" } },
                replace  = { a = { bg = palette.red,   fg = palette.bg,  gui = "bold" } },
                command  = { a = { bg = palette.cyan,  fg = palette.bg,  gui = "bold" } },
                inactive = { a = { bg = palette.bg,    fg = palette.muted },
                             b = { bg = palette.bg,    fg = palette.muted },
                             c = { bg = palette.bg,    fg = palette.muted } },
            }
            return {
                options = {
                    theme            = theme,
                    globalstatus     = true,
                    section_separators   = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            }
        end,
    },

    -- ── File explorer ─────────────────────────────────────────────────────────
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            view   = { width = 32, side = "left" },
            renderer = {
                group_empty     = true,
                highlight_git   = true,
                icons = { show = { git = true, folder = true, file = true } },
            },
            filters = { dotfiles = false },
            git     = { enable = true, ignore = false },
        },
        init = function()
            -- Disable netrw (nvim-tree replacement)
            vim.g.loaded_netrw       = 1
            vim.g.loaded_netrwPlugin = 1
        end,
    },

    -- ── Bufferline (tabs) ─────────────────────────────────────────────────────
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = {
            options = {
                diagnostics        = "nvim_lsp",
                offsets            = { { filetype = "NvimTree", text = "Explorer", padding = 1 } },
                show_buffer_close_icons = false,
                separator_style    = "slant",
            },
        },
    },

    -- ── Which-key ─────────────────────────────────────────────────────────────
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            plugins = { spelling = true },
            win     = { border = "rounded" },
        },
    },

    -- ── Indent guides ─────────────────────────────────────────────────────────
    {
        "lukas-reineke/indent-blankline.nvim",
        main  = "ibl",
        event = "BufReadPost",
        opts  = {
            indent = { char = "│", highlight = "IblIndent" },
            scope  = { enabled = true, highlight = "IblScope" },
        },
        config = function(_, opts)
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#263241" })
            vim.api.nvim_set_hl(0, "IblScope",  { fg = "#3A8DFF" })
            require("ibl").setup(opts)
        end,
    },

    -- ── Notifications + command UI ────────────────────────────────────────────
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
        opts = {
            lsp    = { override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
            }},
            notify = { enabled = true },
            presets = { bottom_search = true, command_palette = true, long_message_to_split = true },
        },
        config = function(_, opts)
            require("notify").setup({
                background_colour = "#0B0F14",
                stages = "slide",
                timeout = 3000,
            })
            require("noice").setup(opts)
        end,
    },

    -- ── Dashboard ─────────────────────────────────────────────────────────────
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            theme = "doom",
            config = {
                header = {
                    "",
                    "  ██████╗ ██╗ ██████╗███████╗    ███████╗███████╗████████╗██╗   ██╗██████╗ ",
                    "  ██╔══██╗██║██╔════╝██╔════╝    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗",
                    "  ██████╔╝██║██║     █████╗      ███████╗█████╗     ██║   ██║   ██║██████╔╝",
                    "  ██╔══██╗██║██║     ██╔══╝      ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ ",
                    "  ██║  ██║██║╚██████╗███████╗    ███████║███████╗   ██║   ╚██████╔╝██║     ",
                    "  ╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝    ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ",
                    "",
                },
                center = {
                    { icon = "  ", key = "f", desc = "Find file",    action = "Telescope find_files" },
                    { icon = "  ", key = "r", desc = "Recent files", action = "Telescope oldfiles" },
                    { icon = "  ", key = "g", desc = "Live grep",    action = "Telescope live_grep" },
                    { icon = "  ", key = "e", desc = "File explorer",action = "NvimTreeToggle" },
                    { icon = "  ", key = "q", desc = "Quit",         action = "qa" },
                },
            },
        },
    },
}
