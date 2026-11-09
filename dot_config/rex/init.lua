-- Keep Rex's own Cmd shortcuts (e.g. Cmd+Enter best-fit split) and add the
-- Herdr Ctrl+B prefix on top. Herdr workspaces are Rex sessions.
-- https://www.superlogical.com/rex/docs/customize/keyboard-shortcuts
-- Shortcuts recorded in the app (Change Shortcut...) override this file, so
-- make changes here instead. Debug the merged result with `rex keymap`.

-- Herdr's Ctrl+B prefix.
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
rex.bind("ctrl+b>shift+p", "pane.rename")
rex.bind("ctrl+b>z", "pane.zoom")

for index = 1, 9 do
	rex.bind("ctrl+b>" .. index, "client.tab.goto", { index = index })
end

-- Resize (Ctrl+B, R) and move (Ctrl+B, M) modes: H/J/K/L or arrows act on the
-- focused pane; Enter/Escape to leave.
for mode, key in pairs({ resize = "r", move = "m" }) do
	rex.mode(mode, { exclusive = true })
	rex.bind("ctrl+b>" .. key, "client.mode.enter", { name = mode })
	rex.bind(mode .. "/enter", "client.mode.exit")
	rex.bind(mode .. "/escape", "client.mode.exit")
end

for _, movement in ipairs({
	{ key = "h", direction = "left" },
	{ key = "j", direction = "down" },
	{ key = "k", direction = "up" },
	{ key = "l", direction = "right" },
}) do
	local key, direction = movement.key, movement.direction
	rex.bind("ctrl+b>" .. key, "pane.focus", { direction = direction, wrap = false })
	rex.bind("ctrl+b>shift+" .. key, "pane.move", { direction = direction })
	rex.bind("resize/" .. key, "pane.resize", { direction = direction })
	rex.bind("resize/" .. direction, "pane.resize", { direction = direction })
	rex.bind("move/" .. key, "pane.move", { direction = direction })
	rex.bind("move/" .. direction, "pane.move", { direction = direction })
end

-- Floating panes: Alt+Cmd+Enter floats one, Ctrl+B, F shows/hides it, and
-- Alt+Cmd+C centers it.
rex.bind("ctrl+b>f", "pane.minimize_floating")
rex.action({
	name = "center_floating",
	title = "Center Floating Pane",
	run = function(ctx)
		local view, err = rex.call("session.view", { session_id = ctx.session_id })
		if err ~= nil then
			error(err, 0)
		end
		for _, window in ipairs(view.windows) do
			for _, layer in ipairs(window.layers) do
				for _, block in ipairs(layer.blocks or {}) do
					if layer.kind ~= "tiled" and block.block_id == ctx.block_id then
						local _, resize_err = rex.call("session.resize_layer", {
							session_id = ctx.session_id,
							layer_id = layer.layer_id,
							bounds = { 0.15, 0.1, 0.7, 0.8 },
						})
						if resize_err ~= nil then
							error(resize_err, 0)
						end
						return
					end
				end
			end
		end
		error("The focused pane isn't floating", 0)
	end,
})
rex.bind("alt+cmd+c", "center_floating")

-- Cmd+P opens the command palette instead of Go to Anything (pane.go_to).
rex.bind("cmd+p", "client.palette.toggle")

-- Herdr-only bindings stay unbound here: Ctrl+S copy mode, plugin launchers
-- (Ctrl+B, A/B), worktrees, agent selection and scrollback editing.
