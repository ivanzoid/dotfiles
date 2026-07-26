--------------------------------------------------------------------------------
-- Ghostty Cmd+T / Cmd+N -> new tab/window that re-connects (ssh/mosh) into the
-- SAME remote directory as the current tab.
--
-- The only channel that carries the live remote cwd back to the Mac is the outer
-- window title: ~/.tmux.conf sets it to "[host] cmd: path" (tmux swallows OSC-7,
-- so there is no other signal). mosh-client prepends its own status bracket, so
-- what actually reaches Ghostty is "[mosh] [host] cmd: path" (the prefix can also
-- read "[mosh: 5s]" etc. when the link stalls). So we read the focused Ghostty
-- window title, skip any leading status brackets to the real "[host]", pull out
-- host + dir, then hand off to the shell:
--
--   1. Stage a tiny request file (host + dir + transport) that the new surface's
--      shell claims on startup.
--   2. Open a *native* new tab/window (via Ghostty's "New Tab"/"New Window" menu
--      item, falling back to the cmd+ctrl+t / cmd+ctrl+n binds).
--
-- The new surface's login shell picks it up at the very top of ~/.zprofile and
-- execs ~/bin/ghostty-reconnect *before* any heavy shell init runs, so there is
-- no wasted local shell startup and nothing to type or poll for. See
-- ~/bin/ghostty-reconnect for the connect logic (host->target mapping, the
-- mosh/ssh command, cd + fresh tmux session).
--
-- The transport is mirrored from the current tab: the "[mosh]" prefix means the
-- session is mosh (reconnect with mosh), its absence means ssh (reconnect with
-- ssh).
--
-- A local (non-ssh) tab has a title like "ivan@mac:~" (no leading "["), so it
-- just gets a normal local new tab/window (and any stale request is cleared).
--
-- Loaded from init.lua via require("ghostty-remote-tabs"). The hotkeys and app
-- watcher are held on the returned module table so require's cache keeps them
-- alive (a plain local would be garbage-collected).
--------------------------------------------------------------------------------

local M = {}

local GHOSTTY_BID = "com.mitchellh.ghostty"

-- Where the request file lives; must match the reader in ~/.zprofile.
local function requestPath()
    local base = os.getenv("HOME") .. "/.cache"
    hs.fs.mkdir(base) -- no-op if it already exists
    return base .. "/ghostty-reconnect"
end

-- Parse "[mosh] [host] cmd: ~/path" (mosh prefix and "cmd:" both optional) ->
-- transport ("mosh"|"ssh"), host, path. Returns nil host for local tabs (no
-- "[host]" bracket).
local function parseRemoteTitle(title)
    if not title then return nil, nil, nil end
    local s = title:gsub("^%s+", "")
    local transport = s:match("^%[mosh") and "mosh" or "ssh"
    -- Skip leading status brackets (mosh's "[mosh]" etc.): keep dropping a
    -- "[...]" while it is immediately followed by another "[...]", so we land on
    -- the last leading bracket, which is the real host.
    while true do
        local nxt = s:match("^%[[^%]]*%]%s*(.*)$")
        if nxt and nxt:match("^%[") then s = nxt else break end
    end
    local host, rest = s:match("^%[([^%]]*)%]%s*(.*)$")
    if not host or host == "" then return nil, nil, nil end
    rest = rest:gsub("%s*[—–]%s+.*$", "")     -- drop any " — Appname" title suffix
    rest = rest:gsub("^[%w%._%+%-]+:%s+", "") -- drop foreground "cmd: " prefix
    rest = rest:gsub("%s+$", "")
    if rest == "" then rest = nil end
    return transport, host, rest
end

-- Stage the reconnect request the new surface's shell will claim. Format matches
-- ~/bin/ghostty-reconnect: epoch / transport / host / dir (dir may be empty).
local function stageRequest(transport, host, dir)
    local f = io.open(requestPath(), "w")
    if not f then return end
    f:write(string.format("%d\n%s\n%s\n%s\n",
        os.time(), transport or "mosh", host, dir or ""))
    f:close()
end

local function clearRequest()
    os.remove(requestPath())
end

-- Open a native Ghostty tab/window. The menu item is primary: synthesising a
-- keystroke is unreliable while the Cmd key that triggered us is still physically
-- held, whereas selecting the menu item goes through Accessibility and is not
-- affected. Fall back to the cmd+ctrl+* keybind only if the menu title isn't found.
local function openNative(menuTitle, fallbackKey)
    local app = hs.application.get(GHOSTTY_BID)
    if app and app:selectMenuItem(menuTitle) then return end
    hs.eventtap.keyStroke({ "cmd", "ctrl" }, fallbackKey)
end

local function ghosttyNewSurface(kind)
    local win = hs.window.focusedWindow()
    local transport, host, dir = parseRemoteTitle(win and win:title())

    -- Stage the request BEFORE opening the surface so the shell finds it on
    -- startup. Local tabs (no host) clear any stale request instead, so a
    -- leftover from a just-cancelled remote Cmd+N can't hijack a local shell.
    if host then stageRequest(transport, host, dir) else clearRequest() end

    if kind == "tab" then
        openNative("New Tab", "t")
    else
        openNative("New Window", "n")
    end
end

M.newTab = hs.hotkey.new({ "cmd" }, "t", function() ghosttyNewSurface("tab") end)
M.newWin = hs.hotkey.new({ "cmd" }, "n", function() ghosttyNewSurface("window") end)

-- Only capture Cmd+T / Cmd+N while Ghostty is frontmost, so every other app
-- keeps its normal new-tab/new-window shortcuts.
local function syncGhosttyHotkeys()
    local app = hs.application.frontmostApplication()
    if app and app:bundleID() == GHOSTTY_BID then
        M.newTab:enable(); M.newWin:enable()
    else
        M.newTab:disable(); M.newWin:disable()
    end
end

M.watcher = hs.application.watcher.new(function(_, event)
    local w = hs.application.watcher
    if event == w.activated or event == w.deactivated
        or event == w.launched or event == w.terminated then
        syncGhosttyHotkeys()
    end
end)
M.watcher:start()
syncGhosttyHotkeys()

return M
