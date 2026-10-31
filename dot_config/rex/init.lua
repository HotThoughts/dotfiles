-- Match the Herdr + Ghostty shortcuts using native Rex actions.
-- Herdr workspaces are Rex sessions; tabs and panes keep the same meaning.
-- https://www.superlogical.com/rex/docs/customize/keyboard-shortcuts

-- Direct Cmd shortcuts (Ghostty's escape-sequence translations aren't needed).
rex.bind("cmd+n", "client.tab.new")
rex.bind("cmd+enter", "pane.split", { direction = "right" })
rex.bind("cmd+shift+enter", "pane.split", { direction = "down" })
rex.bind("cmd+[", "client.tab.previous")
rex.bind("cmd+]", "client.tab.next")
rex.bind("cmd+shift+[", "session.previous")
rex.bind("cmd+shift+]", "session.next")
rex.bind("cmd+shift+m", "pane.zoom")
rex.bind("cmd+/", "client.sidebar.toggle")
rex.bind("cmd+p", "client.palette.toggle")

-- Keep the familiar Ctrl+B prefix alongside the direct shortcuts.
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })
rex.bind("ctrl+b>s", "client.settings")
rex.bind("ctrl+b>shift+r", "client.config.reload")
-- Closing the client window leaves the server's sessions running (detach).
rex.bind("ctrl+b>d", "client.window.close")
-- Both Herdr navigation pickers use Rex's session picker.
rex.bind("ctrl+b>w", "session.switch")
rex.bind("ctrl+b>g", "session.switch")
rex.bind("ctrl+b>shift+n", "session.new")
rex.bind("ctrl+b>shift+w", "session.rename")
rex.bind("ctrl+b>shift+d", "session.close")
rex.bind("ctrl+b>c", "client.tab.new")
rex.bind("ctrl+b>shift+t", "client.tab.rename")
rex.bind("ctrl+b>p", "client.tab.previous")
rex.bind("ctrl+b>n", "client.tab.next")
rex.bind("ctrl+b>shift+x", "client.tab.close")
rex.bind("ctrl+b>tab", "pane.focus_next")
rex.bind("ctrl+b>shift+tab", "pane.focus_previous")
rex.bind("ctrl+b>v", "pane.split", { direction = "right" })
rex.bind("ctrl+b>-", "pane.split", { direction = "down" })
rex.bind("ctrl+b>x", "pane.close")
rex.bind("ctrl+b>z", "pane.zoom")

for index = 1, 9 do
	rex.bind("ctrl+b>" .. index, "client.tab.goto", { index = index })
end

-- Resize mode: Ctrl+B, R; H/J/K/L or arrows; Enter/Escape to leave.
rex.mode("resize", { exclusive = true })
rex.bind("ctrl+b>r", "client.mode.enter", { name = "resize" })
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")

for _, movement in ipairs({
	{ key = "h", direction = "left" },
	{ key = "j", direction = "down" },
	{ key = "k", direction = "up" },
	{ key = "l", direction = "right" },
}) do
	local key, direction = movement.key, movement.direction
	rex.bind("cmd+" .. direction, "pane.focus", { direction = direction, wrap = false })
	rex.bind("alt+" .. direction, "pane.focus", { direction = direction, wrap = false })
	rex.bind("ctrl+b>" .. key, "pane.focus", { direction = direction, wrap = false })
	rex.bind("ctrl+b>shift+" .. key, "pane.move", { direction = direction })
	rex.bind("resize/" .. key, "pane.resize", { direction = direction })
	rex.bind("resize/" .. direction, "pane.resize", { direction = direction })
end

-- Herdr-only bindings stay unbound here: Ctrl+S copy mode, plugin launchers
-- (Ctrl+B, A/B), worktrees, agent selection, pane renaming and scrollback editing.
