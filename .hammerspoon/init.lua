-- Open the IPC message port so the `hs` command-line tool can talk to us
-- (e.g. `hs -c "hs.reload()"`). Requires the `hs` binary to be installed once
-- from the Console: hs.ipc.cliInstall().
require("hs.ipc")


-- Fire ~/bin/ssh-tint-flip on every macOS light/dark appearance change,
-- event-driven (no polling). Pair with `SSH_TINT_POLL=0` in the ssh/mosh
-- wrapper (~/bin/ssh) to rely purely on this hook.

sshTintWatcher = hs.distributednotifications.new(function()
    -- ~/bin may not be on Hammerspoon's PATH; call the absolute path.
    hs.execute(os.getenv("HOME") .. "/bin/ssh-tint-flip", false)
end, "AppleInterfaceThemeChangedNotification")

sshTintWatcher:start()


-- fn+F5 / fn+F6 -> keyboard backlight down / up.
-- hs.hotkey can't match the fn modifier, so tap at the event level and re-emit
-- the system illumination keys (same effect as the hardware brightness keys).
-- If it doesn't trigger on your Mac, drop the `.fn` check below: with the
-- default laptop keyboard setting, fn+F5 is the only way F5/F6 reach here anyway.
local function illum(dir)
    hs.eventtap.event.newSystemKeyEvent(dir, true):post()   -- key down
    hs.eventtap.event.newSystemKeyEvent(dir, false):post()  -- key up
end

kbBacklightTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
    if not e:getFlags().fn then return false end
    local key = hs.keycodes.map[e:getKeyCode()]
    if key == "f5" then illum("ILLUMINATION_DOWN"); return true end
    if key == "f6" then illum("ILLUMINATION_UP");   return true end
    return false
end)

kbBacklightTap:start()
