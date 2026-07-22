-- Colorscheme: Solarized. You used vim-colors-solarized in Vim; vim-solarized8
-- is the maintained truecolor build, and it honors `set background`. options.lua
-- sets background='light', so you get Solarized Light.
--
-- Prefer kickstart's default instead? Comment out the `solarized` line in
-- lua/lazy-plugins.lua and uncomment `tokyonight` (that file still exists).
---@module 'lazy'
---@type LazySpec
return {
  {
    'lifepillar/vim-solarized8',
    priority = 1000, -- load before other start plugins so highlights apply early
    config = function()
      -- Variants: solarized8, solarized8_high, solarized8_low, solarized8_flat.
      vim.cmd.colorscheme 'solarized8'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
