-- Colorscheme + automatic light/dark switching.
--
-- WHY THIS IS BUILT THE WAY IT IS
-- nvim runs on this Linux box, but the macOS light/dark state lives on your
-- laptop. The usual in-band terminal signals (OSC 11 background query, DEC mode
-- 2031 theme-change notifications) do NOT survive mosh: mosh's own emulator
-- answers them, so nvim never learns Ghostty/macOS's real theme. (Over plain ssh
-- they would work — nvim 0.11+ and tmux 3.6 both support them.)
--
-- So we use an OUT-OF-BAND signal that works over mosh, ssh, anything: a tiny
-- state file this box, `stdpath('state')/background`, containing "light"/"dark".
-- Your Mac writes into it over ssh whenever macOS flips appearance; every running
-- nvim watches it and re-skins instantly. See README.md → "Auto light/dark" for
-- the Mac side.

-- The active theme. Change this one line (+ restart) to switch your default.
-- Installed and previewable via `:Telescope colorscheme`: catppuccin, tokyonight,
-- solarized8. Each maps to a light and a dark variant below.
local ACTIVE = 'catppuccin'

local variants = {
  catppuccin = { light = 'catppuccin-latte', dark = 'catppuccin-mocha' },
  tokyonight = { light = 'tokyonight-day', dark = 'tokyonight-night' },
  solarized8 = { light = 'solarized8', dark = 'solarized8' }, -- follows &background itself
}

local state_file = vim.fs.joinpath(vim.fn.stdpath 'state', 'background')

local function read_state()
  local f = io.open(state_file, 'r')
  if not f then return nil end
  local s = (f:read 'l' or ''):gsub('%s+', '')
  f:close()
  return (s == 'light' or s == 'dark') and s or nil
end

local function write_state(bg)
  local f = io.open(state_file, 'w')
  if f then
    f:write(bg .. '\n')
    f:close()
  end
end

-- Your tmux setup already mirrors macOS light/dark into the server option
-- `@appearance` (see ~/.tmux.conf + ~/bin/ssh). Read it as the startup source of
-- truth when the state file isn't there yet.
local function tmux_appearance()
  if not vim.env.TMUX then
    return nil
  end
  local out = (vim.fn.system { 'tmux', 'show', '-gqv', '@appearance' } or ''):gsub('%s+', '')
  return (out == 'light' or out == 'dark') and out or nil
end

-- (Re)apply the concrete colorscheme for ACTIVE at the current &background.
local function apply_colorscheme()
  local v = variants[ACTIVE]
  local name = (v and v[vim.o.background]) or ACTIVE
  pcall(vim.cmd.colorscheme, name)
end

-- Switch background (light|dark) and re-skin. propagate=true also writes the
-- shared state file, so every OTHER running nvim follows suit.
local function set_background(bg, propagate)
  if bg ~= 'light' and bg ~= 'dark' then
    return
  end
  if propagate then
    write_state(bg)
  end
  if vim.o.background ~= bg then
    vim.o.background = bg -- fires the OptionSet autocmd below → apply_colorscheme()
  else
    apply_colorscheme()
  end
end

local function setup_autoswitch()
  -- Re-skin whenever &background changes for ANY reason: our toggle, the file
  -- watcher, or nvim's own OSC 11 detection (the ssh path, when it works).
  vim.api.nvim_create_autocmd('OptionSet', {
    pattern = 'background',
    callback = apply_colorscheme,
    desc = 'Re-apply colorscheme when background flips',
  })

  -- Initial state, in order of preference: the shared state file, then tmux's
  -- @appearance (your existing macOS-driven signal), then your old default.
  local initial = read_state() or tmux_appearance() or 'light'
  write_state(initial) -- ensure the file exists so we have something to watch
  vim.o.background = initial
  apply_colorscheme()

  -- Live updates: watch the state file. The Mac rewrites it over ssh on every
  -- macOS appearance change; libuv fires this and we follow.
  local handle = vim.uv.new_fs_event()
  local function arm()
    if not handle then
      return
    end
    handle:start(
      state_file,
      {},
      vim.schedule_wrap(function(err)
        if not err then
          local bg = read_state()
          if bg and bg ~= vim.o.background then
            vim.o.background = bg -- triggers the OptionSet autocmd → re-skin
          end
        end
        -- re-arm: an in-place rewrite can invalidate the watch
        pcall(function() handle:stop() end)
        arm()
      end)
    )
  end
  pcall(arm)

  -- Manual controls (work everywhere, no transport needed). Toggling propagates
  -- to your other nvim instances through the shared file.
  vim.api.nvim_create_user_command('Light', function() set_background('light', true) end, { desc = 'Light background' })
  vim.api.nvim_create_user_command('Dark', function() set_background('dark', true) end, { desc = 'Dark background' })
  vim.api.nvim_create_user_command('ToggleBg', function()
    set_background(vim.o.background == 'dark' and 'light' or 'dark', true)
  end, { desc = 'Toggle light/dark background' })
  vim.keymap.set('n', '<leader>tt', '<cmd>ToggleBg<CR>', { desc = '[T]oggle ligh[t]/dark background' })
end

---@module 'lazy'
---@type LazySpec
return {
  {
    'catppuccin/nvim',
    name = 'catppuccin', -- repo dir is 'nvim'; rename to avoid clashes
    priority = 1000, -- load colorschemes before other start plugins
    lazy = false,
    opts = {
      background = { light = 'latte', dark = 'mocha' },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      setup_autoswitch() -- run once, after a colorscheme plugin is available
    end,
  },

  -- Extra schemes, installed so you can preview/switch them. Not applied here.
  { 'folke/tokyonight.nvim', priority = 1000, lazy = false, opts = {} },
  { 'lifepillar/vim-solarized8', priority = 1000, lazy = false },
}
-- vim: ts=2 sts=2 sw=2 et
