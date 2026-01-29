vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.lazy")
require("lazy").setup("plugins")


-- Better defaults
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.undofile = true

-- Enable syntax highlighting
vim.cmd("syntax on")

-- Use GUI colors for subtle grays
vim.o.termguicolors = true

-- Light background
vim.o.background = "light"

-- Base text
vim.api.nvim_set_hl(0, "Normal",      { fg = "#000000", bg = "#ffffff" })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#000000", bg = "#ffffff" })
vim.api.nvim_set_hl(0, "StatusLine",  { fg = "#000000", bg = "#ffffff" })
vim.api.nvim_set_hl(0, "LineNr",      { fg = "#999999", bg = "#ffffff" })
vim.api.nvim_set_hl(0, "CursorLineNr",{ fg = "#000000", bold = true })

-- Line highlight
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#eeeeee" })

-- Visual selection
vim.api.nvim_set_hl(0, "Visual", { fg = "#000000", bg = "#cccccc" })

-- Comments
vim.api.nvim_set_hl(0, "Comment", { fg = "#777777", italic = true })

-- Subtle gray for keywords, strings, numbers, etc.
local gray_groups = {
  "Keyword", "Type", "Statement", "Constant",
  "Number", "Boolean", "String", "Identifier",
  "Function", "Operator", "Delimiter", "PreProc",
  "Special", "Structure", "Conditional", "Repeat"
}
for _, g in ipairs(gray_groups) do
  vim.api.nvim_set_hl(0, g, { fg = "#444444" })
end



local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ===== CORE LIFECYCLE =====
map('n', '<leader>w', '<cmd>w<CR>', opts)           -- write
map('n', '<leader>q', '<cmd>q<CR>', opts)           -- quit
map('n', '<leader>x', '<cmd>wq<CR>', opts)          -- write + quit
map('n', '<leader>Q', '<cmd>qa!<CR>', opts)         -- force quit all

-- ===== SYSTEM / CONTROL PLANE =====
map('n', '<leader>L', '<cmd>Lazy<CR>', opts)        -- plugin manager (capital L to avoid conflicts)
map('n', '<leader>m', '<cmd>Mason<CR>', opts)       -- LSP manager
map('n', '<leader>li', '<cmd>LspInfo<CR>', opts)    -- LSP info

-- ===== FILESYSTEM =====
map('n', '<leader>e', '<cmd>Oil<CR>', opts)         -- file explorer (current dir parent)
map('n', '<leader>E', '<cmd>Oil .<CR>', opts)       -- file explorer (project root)
map('n', '-', '<cmd>Oil<CR>', opts)                 -- quick parent directory

-- ===== NAVIGATION =====
map('n', '<leader><leader>', '<cmd>nohlsearch<CR>', opts) -- clear search highlight
map('n', '<leader>c', '<cmd>bd<CR>', opts)          -- close buffer
map('n', '<Tab>', '<cmd>bnext<CR>', opts)           -- next buffer
map('n', '<S-Tab>', '<cmd>bprev<CR>', opts)         -- previous buffer

-- ===== WINDOW MANAGEMENT =====
map('n', '<C-h>', '<C-w>h', opts)                   -- focus left window
map('n', '<C-j>', '<C-w>j', opts)                   -- focus down window
map('n', '<C-k>', '<C-w>k', opts)                   -- focus up window
map('n', '<C-l>', '<C-w>l', opts)                   -- focus right window
map('n', '<leader>sv', '<cmd>vsplit<CR>', opts)     -- vertical split
map('n', '<leader>sh', '<cmd>split<CR>', opts)      -- horizontal split

-- ===== EDITING ENHANCEMENTS =====
map('n', '<leader>p', '"+p', opts)                  -- paste from system clipboard
map('v', '<leader>y', '"+y', opts)                  -- yank to system clipboard
map('n', '<leader>Y', '"+Y', opts)                  -- yank line to system clipboard
map('v', '<', '<gv', opts)                          -- stay in visual mode after indent left
map('v', '>', '>gv', opts)                          -- stay in visual mode after indent right
map('v', 'J', ":m '>+1<CR>gv=gv", opts)            -- move selection down
map('v', 'K', ":m '<-2<CR>gv=gv", opts)            -- move selection up

-- ===== SEARCH & REPLACE =====
map('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], 
  { noremap = true, desc = 'Search and replace word under cursor' })

-- ===== LATEX (VimTeX) =====
map('n', '<leader>lc', '<cmd>VimtexCompile<CR>', opts)   -- compile
map('n', '<leader>lv', '<cmd>VimtexView<CR>', opts)      -- view PDF
map('n', '<leader>ls', '<cmd>VimtexStop<CR>', opts)      -- stop compile
map('n', '<leader>le', '<cmd>VimtexErrors<CR>', opts)    -- show errors
map('n', '<leader>lt', '<cmd>VimtexTocToggle<CR>', opts) -- toggle TOC

-- ===== TERMINAL =====
map('n', '<leader>t', '<cmd>terminal<CR>i', opts)        -- open terminal
map('t', '<Esc>', '<C-\\><C-n>', opts)                   -- exit terminal mode

-- ===== QUALITY OF LIFE =====
map('n', 'J', 'mzJ`z', opts)                        -- join lines but keep cursor position
map('n', '<C-d>', '<C-d>zz', opts)                  -- half page down + center
map('n', '<C-u>', '<C-u>zz', opts)                  -- half page up + center
map('n', 'n', 'nzzzv', opts)                        -- next search result + center
map('n', 'N', 'Nzzzv', opts)                        -- prev search result + center
