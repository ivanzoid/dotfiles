-- oil.nvim: browse and EDIT the filesystem as if it were a normal buffer.
--   -   jump to the parent directory
--   then edit a name to rename, `dd` to delete, add a line to create a file,
--   and `:w` to apply your changes to disk.
-- A modern replacement for netrw (you had a .netrwhist in your old ~/.vim).
---@module 'lazy'
---@type LazySpec
return {
  {
    'stevearc/oil.nvim',
    lazy = false, -- so `-` works immediately, and `nvim <dir>` opens in oil
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Want file-type icons? Install a Nerd Font, set vim.g.have_nerd_font = true
    -- in init.lua, then add: dependencies = { 'nvim-tree/nvim-web-devicons' }
    config = function(_, opts)
      require('oil').setup(opts)
      vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory (oil)' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
