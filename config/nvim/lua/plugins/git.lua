return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts  = {
            signs = {
                add          = { text = "▎" },
                change       = { text = "▎" },
                delete       = { text = "" },
                topdelete    = { text = "" },
                changedelete = { text = "▎" },
                untracked    = { text = "▎" },
            },
            on_attach = function(bufnr)
                local gs  = package.loaded.gitsigns
                local map = function(mode, keys, func, desc)
                    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "Git: " .. desc })
                end
                -- Navigation
                map("n", "]h", gs.next_hunk,          "Next hunk")
                map("n", "[h", gs.prev_hunk,          "Prev hunk")
                -- Actions
                map("n", "<leader>hs", gs.stage_hunk,         "Stage hunk")
                map("n", "<leader>hr", gs.reset_hunk,         "Reset hunk")
                map("v", "<leader>hs", function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end, "Stage hunk")
                map("n", "<leader>hS", gs.stage_buffer,       "Stage buffer")
                map("n", "<leader>hu", gs.undo_stage_hunk,    "Undo stage hunk")
                map("n", "<leader>hR", gs.reset_buffer,       "Reset buffer")
                map("n", "<leader>hp", gs.preview_hunk,       "Preview hunk")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
                map("n", "<leader>hd", gs.diffthis,           "Diff this")
                map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle blame")
            end,
        },
    },
}
