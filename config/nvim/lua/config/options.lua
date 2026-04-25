local opt = vim.opt

-- UI
opt.number         = true
opt.relativenumber = true
opt.signcolumn     = "yes"
opt.cursorline     = true
opt.colorcolumn    = "100"
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.termguicolors  = true
opt.showmode       = false       -- lualine handles this
opt.pumheight      = 10
opt.conceallevel   = 2

-- Indentation
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.softtabstop    = 4
opt.expandtab      = true
opt.smartindent    = true
opt.shiftround     = true

-- Search
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = true
opt.incsearch      = true

-- Files
opt.undofile       = true
opt.swapfile       = false
opt.backup         = false
opt.autowrite      = true
opt.fileencoding   = "utf-8"

-- Splits
opt.splitright     = true
opt.splitbelow     = true

-- Performance
opt.updatetime     = 200
opt.timeoutlen     = 300
opt.lazyredraw     = false       -- keep false for smooth macros

-- Clipboard (Wayland via wl-clipboard)
opt.clipboard      = "unnamedplus"

-- Completion
opt.completeopt    = { "menu", "menuone", "noselect" }

-- Fold (handled by treesitter)
opt.foldmethod     = "expr"
opt.foldexpr       = "nvim_treesitter#foldexpr()"
opt.foldenable     = false       -- open all folds by default
