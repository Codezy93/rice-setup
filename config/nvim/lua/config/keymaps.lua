local map = vim.keymap.set

vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

-- ── General ───────────────────────────────────────────────────────────────────
map("n", "<Esc>",        "<cmd>nohlsearch<cr>",          { desc = "Clear search highlight" })
map("n", "<leader>w",    "<cmd>w<cr>",                   { desc = "Save" })
map("n", "<leader>q",    "<cmd>q<cr>",                   { desc = "Quit" })
map("n", "<leader>Q",    "<cmd>qa!<cr>",                 { desc = "Quit all" })

-- ── Navigation ────────────────────────────────────────────────────────────────
map("n", "<C-h>",        "<C-w>h",                       { desc = "Go to left window" })
map("n", "<C-j>",        "<C-w>j",                       { desc = "Go to lower window" })
map("n", "<C-k>",        "<C-w>k",                       { desc = "Go to upper window" })
map("n", "<C-l>",        "<C-w>l",                       { desc = "Go to right window" })

-- Resize
map("n", "<C-Up>",       "<cmd>resize +2<cr>",           { desc = "Increase window height" })
map("n", "<C-Down>",     "<cmd>resize -2<cr>",           { desc = "Decrease window height" })
map("n", "<C-Left>",     "<cmd>vertical resize -2<cr>",  { desc = "Decrease window width" })
map("n", "<C-Right>",    "<cmd>vertical resize +2<cr>",  { desc = "Increase window width" })

-- Better up/down on wrapped lines
map({ "n", "x" }, "j",  "v:count == 0 ? 'gj' : 'j'",   { expr = true })
map({ "n", "x" }, "k",  "v:count == 0 ? 'gk' : 'k'",   { expr = true })

-- Buffer navigation
map("n", "<S-h>",        "<cmd>bprevious<cr>",           { desc = "Prev buffer" })
map("n", "<S-l>",        "<cmd>bnext<cr>",               { desc = "Next buffer" })
map("n", "<leader>bd",   "<cmd>bdelete<cr>",             { desc = "Delete buffer" })

-- ── Editing ───────────────────────────────────────────────────────────────────
-- Stay in visual mode after indent
map("v", "<",            "<gv")
map("v", ">",            ">gv")

-- Move lines
map("n", "<A-j>",        "<cmd>m .+1<cr>==",             { desc = "Move line down" })
map("n", "<A-k>",        "<cmd>m .-2<cr>==",             { desc = "Move line up" })
map("v", "<A-j>",        ":m '>+1<cr>gv=gv",             { desc = "Move selection down" })
map("v", "<A-k>",        ":m '<-2<cr>gv=gv",             { desc = "Move selection up" })

-- Paste without overwriting register
map("x", "<leader>p",    '"_dP',                         { desc = "Paste without yanking" })

-- Delete without yanking
map({ "n", "v" }, "<leader>d", '"_d',                   { desc = "Delete without yanking" })

-- ── Telescope ─────────────────────────────────────────────────────────────────
map("n", "<leader>ff",   "<cmd>Telescope find_files<cr>",   { desc = "Find files" })
map("n", "<leader>fg",   "<cmd>Telescope live_grep<cr>",    { desc = "Live grep" })
map("n", "<leader>fb",   "<cmd>Telescope buffers<cr>",      { desc = "Buffers" })
map("n", "<leader>fh",   "<cmd>Telescope help_tags<cr>",    { desc = "Help tags" })
map("n", "<leader>fr",   "<cmd>Telescope oldfiles<cr>",     { desc = "Recent files" })
map("n", "<leader>fs",   "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document symbols" })

-- ── File tree ─────────────────────────────────────────────────────────────────
map("n", "<leader>e",    "<cmd>NvimTreeToggle<cr>",         { desc = "File explorer" })

-- ── LSP (set in lsp.lua on_attach, but global fallbacks here) ─────────────────
map("n", "<leader>cd",   vim.diagnostic.open_float,         { desc = "Line diagnostics" })
map("n", "[d",           vim.diagnostic.goto_prev,          { desc = "Prev diagnostic" })
map("n", "]d",           vim.diagnostic.goto_next,          { desc = "Next diagnostic" })

-- ── Misc ──────────────────────────────────────────────────────────────────────
map("n", "<leader>gg",   "<cmd>LazyGit<cr>",                { desc = "LazyGit" })
map("n", "<leader>un",   "<cmd>Noice dismiss<cr>",          { desc = "Dismiss notifications" })
