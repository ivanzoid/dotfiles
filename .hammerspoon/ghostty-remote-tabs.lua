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
-- host + dir, open a *native* new tab/window (via Ghostty's "New Tab"/"New Window"
-- menu item, falling back to the cmd+ctrl+t / cmd+ctrl+n binds), wait for its local
-- shell prompt, then type a connect command that lands in that dir in a fresh tmux
-- session.
--
-- The transport is mirrored from the current tab: the "[mosh]" prefix means the
-- session is mosh (reconnect with mosh), its absence means ssh (reconnect with
-- ssh).
--
-- A local (non-ssh) tab has a title like "ivan@mac:~" (no leading "["), so it
-- just gets a normal local new tab/window with nothing typed.
--
-- Loaded from init.lua via require("ghostty-remote-tabs"). The hotkeys and app
-- watcher are held on the returned module table so require's cache keeps them
-- alive (a plain local would be garbage-collected).
--------------------------------------------------------------------------------

local M = {}

local GHOSTTY_BID = "com.mitchellh.ghostty"

-- How the title's "[host]" maps to a working connect target. Unknown hosts fall
-- back to "ivan@<host>". Add entries as you connect to more hosts.
local HOST_TARGETS = {
    ai = "ivan@ai.local",
}

local function targetForHost(host)
    return HOST_TARGETS[host] or ("ivan@" .. host)
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

local function connectCommand(transport, host, dir)
    local target = targetForHost(host)
    if transport == "mosh" then
        if dir then
            local remoteDir = dir:gsub("^~", "$HOME") -- expand ~ on the remote side
            -- mosh execs the command directly (no remote shell wrapper), so we
            -- invoke a non-interactive login zsh: it gets PATH, skips the
            -- interactive tmux chooser, then execs a fresh (auto-named) tmux
            -- session in that dir. "--" goes *before* the host so mosh's option
            -- parser doesn't eat the command's flags (e.g. zsh's "-lc").
            return string.format(
                "mosh -- %s zsh -lc 'cd \"%s\" 2>/dev/null; exec tmux new-session -s \"$($HOME/.tmux/session-name.sh)\"'",
                target, remoteDir)
        end
        return string.format("mosh %s", target)
    else -- ssh
        if dir then
            local remoteDir = dir:gsub("^~", "$HOME") -- expanded by the remote $SHELL -c
            -- ssh runs the command via the remote login shell ($SHELL -c), so no
            -- explicit shell is needed; -t forces a PTY for tmux. tmux is on the
            -- default PATH, and running non-interactively skips the tmux chooser.
            return string.format(
                "ssh -t %s 'cd \"%s\" 2>/dev/null; exec tmux new-session -s \"$($HOME/.tmux/session-name.sh)\"'",
                target, remoteDir)
        end
        return string.format("ssh %s", target)
    end
end

-- Type the command, then press Return. keyStrokes types via a unicode payload on
-- a keycode-0 event; a literal "\n" isn't read from that payload, so the terminal
-- falls back to keycode 0 (an "a") instead of executing. So type the text, then
-- send a real Return key event (small delay so all typed chars land first).
local function typeAndRun(cmd)
    hs.eventtap.keyStrokes(cmd)
    hs.timer.doAfter(0.05, function() hs.eventtap.keyStroke({}, "return") end)
end

-- Run the command once the new local tab reaches its shell prompt (its title
-- looks like "user@host:"). Never type while the focused tab still shows a remote
-- "[host] …" title — that would start the connection inside the existing session.
-- Give up after ~3s rather than risk that.
local function typeWhenReady(cmd, attempts)
    attempts = attempts or 0
    local win = hs.window.focusedWindow()
    local t = (win and win:title()) or ""
    local isRemote = t:match("^%[") ~= nil
    local ready = (not isRemote) and t:match("^[%w._%-]+@[%w._%-]+:") ~= nil
    if ready then
        typeAndRun(cmd)
    elseif attempts >= 30 then
        if not isRemote then typeAndRun(cmd) end -- last resort, only if not still remote
    else
        hs.timer.doAfter(0.1, function() typeWhenReady(cmd, attempts + 1) end)
    end
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

    if kind == "tab" then
        openNative("New Tab", "t")
    else
        openNative("New Window", "n")
    end

    if not host then return end -- local tab: leave it as a plain local shell
    typeWhenReady(connectCommand(transport, host, dir))
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
