return {
    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        cmd          = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        opts = {
            defaults = {
                prompt_prefix   = "  ",
                selection_caret = " ",
                entry_prefix    = "  ",
                border          = true,
                layout_strategy = "horizontal",
                layout_config   = { prompt_position = "top", width = 0.85, height = 0.85 },
                sorting_strategy = "ascending",
                file_ignore_patterns = { "node_modules", ".git/", "__pycache__" },
            },
        },
        config = function(_, opts)
            require("telescope").setup(opts)
            require("telescope").load_extension("fzf")
        end,
    },

    -- Auto-pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts  = { check_ts = true },
        config = function(_, opts)
            local autopairs = require("nvim-autopairs")
            autopairs.setup(opts)
            -- Connect to nvim-cmp
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    -- Comment toggling
    {
        "numToStr/Comment.nvim",
        keys = {
            { "gcc", mode = "n" },
            { "gc",  mode = "v" },
        },
        opts = {},
    },

    -- Surround
    {
        "kylechui/nvim-surround",
        version = "*",
        event   = "VeryLazy",
        opts    = {},
    },

    -- Flash: fast motion
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts  = {},
        keys  = {
            { "s",     function() require("flash").jump() end,              mode = { "n", "x", "o" }, desc = "Flash" },
            { "S",     function() require("flash").treesitter() end,        mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
            { "r",     function() require("flash").remote() end,            mode = "o",               desc = "Remote Flash" },
            { "<C-s>", function() require("flash").toggle() end,            mode = "c",               desc = "Toggle Flash Search" },
        },
    },

    -- Todo comments
    {
        "folke/todo-comments.nvim",
        event        = "BufReadPost",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts         = { signs = true },
    },

    -- Trouble: diagnostics panel
    {
        "folke/trouble.nvim",
        cmd  = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                       desc = "Diagnostics" },
            { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",          desc = "Buffer diagnostics" },
            { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                           desc = "Location list" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                            desc = "Quickfix list" },
        },
        opts = {},
    },

    -- LazyGit integration
    {
        "kdheepak/lazygit.nvim",
        cmd          = "LazyGit",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
}
