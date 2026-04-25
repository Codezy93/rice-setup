return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        opts = {
            ensure_installed = {
                "bash", "c", "cpp", "css", "dockerfile",
                "go", "html", "javascript", "json", "lua",
                "markdown", "markdown_inline", "python",
                "regex", "rust", "scss", "toml", "tsx",
                "typescript", "vim", "vimdoc", "yaml",
            },
            auto_install    = true,
            highlight       = { enable = true },
            indent          = { enable = true },
            incremental_selection = {
                enable  = true,
                keymaps = {
                    init_selection    = "<C-space>",
                    node_incremental  = "<C-space>",
                    scope_incremental = false,
                    node_decremental  = "<bs>",
                },
            },
            textobjects = {
                select = {
                    enable    = true,
                    lookahead = true,
                    keymaps   = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        ["aa"] = "@parameter.outer",
                        ["ia"] = "@parameter.inner",
                    },
                },
                move = {
                    enable              = true,
                    set_jumps           = true,
                    goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
                    goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}
