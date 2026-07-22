# Ivan's Neovim config

Based on [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim)
(the `lazy` branch — lazy.nvim manager), trimmed to a minimal plugin set and with
my old `~/.vimrc` settings/keymaps embedded. Lives in `~/dotfiles/.config/nvim`,
symlinked into `~/.config/nvim` by `deploy.sh`.

## Layout

| File | What's in it |
|------|--------------|
| `init.lua` | Entry point: sets leader (`Space`), then requires the files below |
| `lua/options.lua` | kickstart's `:set` defaults **+ my `.vimrc` settings appended at the end** |
| `lua/keymaps.lua` | kickstart keymaps **+ my `.vimrc` mappings, `:Retab`, text-`textwidth` autocmd** |
| `lua/lazy-bootstrap.lua` | Auto-installs the lazy.nvim plugin manager on first launch |
| `lua/lazy-plugins.lua` | **The plugin toggle list.** Enable/disable a plugin = (un)comment one line |
| `lua/kickstart/plugins/*.lua` | One file per plugin (telescope, lspconfig, treesitter, …) |

## Enabled now

`telescope` (fuzzy finder) · `solarized` (colorscheme) · `lualine` (statusline) · `oil` (file explorer).

Everything else in the kickstart kit is present but commented out in
`lua/lazy-plugins.lua`. To turn one on: uncomment its line, restart nvim, done.
The big ones waiting there: **treesitter**, **lspconfig** (IDE features — run
`:Mason` to install `gopls`/`lua_ls`), **blink-cmp** (completion), **gitsigns**,
**which-key**.

## Managing it

- `:Lazy` — plugin status / install / update (`U` to update, `?` for help)
- `:Mason` — install language servers/formatters (only after enabling lspconfig)
- `:checkhealth` — diagnose problems (start here if something's off)
- `:Tutor` — the built-in 20-minute Neovim tutorial

The plugin lockfile (`lazy-lock.json`) is written straight into this repo so
pinned versions sync to your Macs — commit it after `:Lazy update`.

## From your old Vim — what changed

| Old habit | Now |
|-----------|-----|
| `:e path` / netrw | `-` opens **oil** (edit the fs as a buffer); `:e` still works |
| `:vimgrep` / `:grep` | `<leader>sg` — live grep (ripgrep) across the project |
| `:find` / `:ls`+`:b` | `<leader>sf` files, `<leader><leader>` buffers |
| `<C-j>`/`<C-k>` tabs | **unchanged** — still tab prev/next (kickstart's window maps on these are off) |
| `<C-h>`/`<C-l>` | move between **splits** (new) |
| `F2` save, `F4` quickfix, `F5`/`F6` buffers, `F10` close | **unchanged** |
| `j`/`k` | still move by screen line (your `gj`/`gk`) |
| your `set statusline` | now **lualine** (same info, prettier) |
| `~/.vimrc` | this directory; `~/.vim/bundle` (Pathogen/Vundle) → lazy.nvim |

`Space` is the **leader** key (new). Tap it and pause to see grouped commands
once you enable which-key. `<leader>s...` = search family, `<leader>f...` = files.

## Learning path

1. `:Tutor` if the basics are rusty.
2. Read `lua/options.lua` and `lua/keymaps.lua` top-to-bottom — they're commented.
3. When you want IDE features, uncomment `lspconfig` + `blink-cmp` + `treesitter`
   in `lua/lazy-plugins.lua`, restart, and open a Go/Lua file — Mason installs the
   server automatically.
