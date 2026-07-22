-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Enable break indent
vim.o.breakindent = true

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- ════════════════════════════════════════════════════════════════════════════
-- Ivan's settings, ported from ~/.vimrc. These run AFTER kickstart's defaults
-- above, so anything set here wins. Tweak freely.
-- ════════════════════════════════════════════════════════════════════════════

-- Indentation: real tabs, 4 columns wide (your `ts=4 sw=4 noexpandtab`).
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false
vim.o.wrap = true -- your `set wrap` (soft-wrap long lines)

-- NOTE: &background is NOT hardcoded here anymore. It's driven by the theme
-- machinery in lua/kickstart/plugins/colorscheme.lua, which reads a shared state
-- file (defaulting to light) and follows macOS light/dark. See that file + README.

-- Command-line completion + split behaviour (your wildmode / switchbuf).
vim.o.wildmode = 'list:longest'
vim.o.switchbuf = 'split'

-- Your `cpoptions+=n`: wrapped lines reuse the line-number column.
vim.opt.cpoptions:append 'n'

-- Your listchars. NOTE: your .vimrc never ran `set list`, so whitespace stayed
-- hidden day-to-day — matched here with list=false (kickstart turned it ON).
-- Toggle it live any time with `:set list!`.
vim.o.list = false
vim.opt.listchars = { tab = '>.', trail = '.', eol = '$' }

-- Your scroll padding (kickstart used scrolloff=10; you preferred 2).
vim.o.scrolloff = 2
vim.o.sidescrolloff = 2

-- Dropped as redundant — Neovim already enables these by default: incsearch,
-- hlsearch, showcmd, laststatus=2, autoindent, `syntax on`, `filetype plugin
-- indent on`, utf-8, backspace, display=lastline. Your history=1024 was BELOW
-- nvim's default of 10000, so dropping it is a free upgrade. The $GOROOT/misc/vim
-- block was dead code — Go removed misc/vim in 1.19; the gopls language server is
-- the modern replacement (flip on kickstart.plugins.lspconfig to get it).
--
-- Kept from kickstart (new vs your old Vim, delete above if unwanted): line
-- numbers, cursorline, mouse=a, persistent undofile, clipboard=unnamedplus,
-- inccommand=split (live :substitute preview).

-- vim: ts=2 sts=2 sw=2 et
