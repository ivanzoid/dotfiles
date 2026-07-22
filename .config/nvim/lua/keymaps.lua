-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- NOTE: your .vimrc uses <C-j>/<C-k> for TAB navigation (see the "Ivan's
-- mappings" block at the bottom of this file), so kickstart's window-move maps
-- on those two keys are disabled here. <C-h>/<C-l> still move between windows.
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- ════════════════════════════════════════════════════════════════════════════
-- Ivan's mappings, ported from ~/.vimrc.
-- `map(modes, lhs, rhs)` is non-recursive by default (like Vim's `noremap`).
-- ════════════════════════════════════════════════════════════════════════════
local map = vim.keymap.set

-- Quit with Ctrl-C. NOTE: overrides Neovim's usual Ctrl-C (interrupt/cancel).
-- Delete these three lines to restore the default.
map('i', '<C-c>', '<Esc>:q<CR>')
map('n', '<C-c>', ':q<CR>')
map('x', '<C-c>', '<Esc>:q<CR>')

-- Tab navigation, your <C-j> / <C-k> (see the window-move note higher up).
map({ 'n', 'v' }, '<C-j>', ':tabprev<CR>')
map({ 'n', 'v' }, '<C-k>', ':tabnext<CR>')

-- Save with F2.
map({ 'n', 'v' }, '<F2>', ':w<CR>')
map('i', '<F2>', '<Esc>:w<CR>l')

-- Quickfix navigation, F4 / Shift-F4. Heads-up: many terminals/tmux can't send
-- Shift-F<n> as a distinct code, so <S-F4> may do nothing; <F4> alone is reliable.
map({ 'n', 'v' }, '<F4>', ':cnext<CR>')
map({ 'n', 'v' }, '<S-F4>', ':cprev<CR>')

-- Buffer navigation, F5 / F6.
map({ 'n', 'v' }, '<F5>', ':bprev<CR>')
map({ 'n', 'v' }, '<F6>', ':bnext<CR>')

-- Close window / next preview-tag, F10 / Shift-F10.
map({ 'n', 'v' }, '<F10>', ':close<CR>')
map({ 'n', 'v' }, '<S-F10>', ':ptnext<CR>')
map('i', '<S-F10>', '<Esc>:ptnext<CR>')

-- Move by screen line when a line wraps (your j/k → gj/gk).
map({ 'n', 'v' }, 'j', 'gj')
map({ 'n', 'v' }, 'k', 'gk')
map({ 'n', 'v' }, '<Down>', 'gj')
map({ 'n', 'v' }, '<Up>', 'gk')
map('i', '<Down>', '<C-o>gj')
map('i', '<Up>', '<C-o>gk')

-- Your :Retab {n} command — collapse runs of {n} leading spaces into tabs over a
-- range. Kept verbatim as Vimscript: the regex uses Vim's \v / \%(...) syntax.
vim.cmd [[command! -nargs=1 -range Retab <line1>,<line2>s/\v%(^ *)@<= {<args>}/\t/g]]

-- Your `autocmd FileType text setlocal textwidth=100`.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'textwidth=100 for plain-text files',
  pattern = 'text',
  callback = function() vim.opt_local.textwidth = 100 end,
})

-- vim: ts=2 sts=2 sw=2 et
