-- Statusline. Replaces kickstart's mini.statusline. The sections below roughly
-- mirror the `set statusline=...` you hand-wrote in Vim: filename, filetype,
-- percent-through-file, and line:column.
---@module 'lazy'
---@type LazySpec
return {
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'auto', -- follows the active colorscheme (Solarized)
        icons_enabled = vim.g.have_nerd_font,
        section_separators = '',
        component_separators = '|',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1 } }, -- relative path, like your %f
        lualine_x = { 'filetype' }, --                like your %y
        lualine_y = { 'progress' }, --                like your [%p%%]
        lualine_z = { 'location' }, --                like your L[%l/%L] C[%v]
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
