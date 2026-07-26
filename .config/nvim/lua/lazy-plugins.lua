-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added via a link or github org/name. To run setup automatically, use `opts = {}`
  -- modular approach: using `require 'path.name'` will
  -- include a plugin definition from file lua/path/name.lua

  -- ══════════════════════════════════════════════════════════════════════════
  -- ENABLED NOW — your minimal starting set
  -- ══════════════════════════════════════════════════════════════════════════
  require 'kickstart.plugins.telescope', --   fuzzy finder (<leader>sf files, <leader>sg grep, …)
  require 'kickstart.plugins.colorscheme', -- theme + auto light/dark (catppuccin; :ToggleBg)
  require 'kickstart.plugins.lualine', --     statusline (replaces kickstart's mini.statusline)
  require 'kickstart.plugins.oil', --      file explorer; edit the filesystem as a buffer (press `-`)

  -- ══════════════════════════════════════════════════════════════════════════
  -- FLIP ON LATER — the rest of the kickstart kit. Uncomment a line + restart
  -- nvim to enable it. Every file below already exists; it just isn't loaded.
  -- ══════════════════════════════════════════════════════════════════════════
  -- require 'kickstart.plugins.treesitter',    -- accurate syntax highlighting + indent
  -- require 'kickstart.plugins.lspconfig',     -- IDE features: go-to-def, hover, rename (:Mason installs servers)
  -- require 'kickstart.plugins.blink-cmp',     -- autocompletion popups (pairs with lspconfig)
  -- require 'kickstart.plugins.conform',       -- format-on-save
  -- require 'kickstart.plugins.gitsigns',      -- git add/change/delete signs in the gutter
  -- require 'kickstart.plugins.which-key',     -- popup listing available keybindings as you type
  -- require 'kickstart.plugins.todo-comments', -- highlight TODO / FIXME / HACK comments
  -- require 'kickstart.plugins.mini',          -- mini.ai + mini.surround (also a statusline; we use lualine)
  -- { 'NMAC427/guess-indent.nvim', opts = {} }, -- auto-detect indent — LEFT OFF: it fights your fixed ts=4/noexpandtab

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  -- { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, { ---@diagnostic disable-line: missing-fields
  -- Keep lazy's plugin lockfile inside the dotfiles repo (~/dotfiles/.config/nvim),
  -- not in ~/.config/nvim (which deploy.sh makes a REAL dir), so pinned plugin
  -- versions get committed and sync to your other machines. Falls back to lazy's
  -- default location if the repo isn't present on this machine.
  lockfile = (vim.fn.isdirectory(vim.fn.expand '~/dotfiles/.config/nvim') == 1) and vim.fn.expand '~/dotfiles/.config/nvim/lazy-lock.json' or nil,
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
