return {
    -- Mason: LSP/linter/formatter installer
    {
        "williamboman/mason.nvim",
        cmd  = "Mason",
        opts = { ui = { border = "rounded" } },
    },

    -- Bridge: mason ↔ lspconfig
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                "lua_ls",
                "ts_ls",          -- TypeScript / JavaScript
                "pyright",        -- Python
                "bashls",         -- Bash
                "cssls",          -- CSS
                "html",           -- HTML
                "jsonls",         -- JSON
                "yamlls",         -- YAML
            },
            automatic_installation = true,
        },
    },

    -- Core LSP config
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            { "folke/neodev.nvim", opts = {} },   -- Neovim Lua API completions
        },
        config = function()
            local lspconfig    = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local on_attach = function(_, bufnr)
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
                end
                map("gd",         vim.lsp.buf.definition,       "Go to definition")
                map("gD",         vim.lsp.buf.declaration,      "Go to declaration")
                map("gr",         "<cmd>Telescope lsp_references<cr>", "References")
                map("gI",         vim.lsp.buf.implementation,   "Go to implementation")
                map("K",          vim.lsp.buf.hover,            "Hover docs")
                map("<C-k>",      vim.lsp.buf.signature_help,   "Signature help")
                map("<leader>rn", vim.lsp.buf.rename,           "Rename")
                map("<leader>ca", vim.lsp.buf.code_action,      "Code action")
                map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")
            end

            -- Default setup for all mason-installed servers
            require("mason-lspconfig").setup_handlers({
                function(server_name)
                    lspconfig[server_name].setup({
                        capabilities = capabilities,
                        on_attach    = on_attach,
                    })
                end,
                -- Lua: add neovim globals
                ["lua_ls"] = function()
                    lspconfig.lua_ls.setup({
                        capabilities = capabilities,
                        on_attach    = on_attach,
                        settings = {
                            Lua = {
                                diagnostics = { globals = { "vim" } },
                                workspace   = { checkThirdParty = false },
                                telemetry   = { enable = false },
                            },
                        },
                    })
                end,
            })

            -- Diagnostic signs + appearance
            local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end

            vim.diagnostic.config({
                virtual_text    = { prefix = "●" },
                update_in_insert = false,
                severity_sort   = true,
                float           = { border = "rounded", source = "always" },
            })
        end,
    },

    -- Formatter (non-LSP)
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        opts = {
            formatters_by_ft = {
                lua        = { "stylua" },
                python     = { "black" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                css        = { "prettier" },
                html       = { "prettier" },
                json       = { "prettier" },
                yaml       = { "prettier" },
                bash       = { "shfmt" },
            },
            format_on_save = { timeout_ms = 500, lsp_fallback = true },
        },
    },
}
