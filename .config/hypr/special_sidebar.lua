local columns = {
	{
		name = "telegram",
		width = 623,
		expanded = 920,
		class = "org.telegram.desktop",
		launch = "Telegram",
		media_viewer = "Media viewer",
	},
	{
		name = "beeper",
		width = 520,
		expanded = 820,
		class = "Beeper",
		launch = "env DESKTOPINTEGRATION=1 /home/zane/AppImages/beeper.appimage --no-sandbox",
	},
}

-- The media viewer wants the whole output. Confining it with tile+maximize worked
-- geometrically but killed the effect it exists for: a workspace that holds a
-- fullscreen/maximized window renders only that window, so the main window behind it is
-- never drawn and its blur samples the wallpaper instead. Keep the viewer *floating* --
-- floats draw over tiled windows on the same workspace, so the chat list is really there
-- behind the glass -- and hand it the column geometry explicitly. suppress_event so a
-- fullscreen/maximize request from the app cannot put it back there.
local function fit_column(col)
	local monitor = hl.get_active_monitor()

	-- A monitor handle whose output has gone away answers nil to every field, and layout
	-- changes are exactly when that happens, so this also covers the reads below.
	if not monitor or not monitor.scale or monitor.scale <= 0 then
		return
	end

	-- Monitor dimensions are physical pixels; gaps, reserved and rule geometry are all
	-- logical, so the scale has to come out before reserved (already logical) comes off.
	-- The scale is a float (4/3 arrives as 1.3333334), so round rather than floor, or the
	-- float lands a pixel short of the tiled column it is supposed to cover exactly.
	local function px(v)
		return math.floor(v + 0.5)
	end

	local reserved = monitor.reserved
	local usable_w = monitor.width / monitor.scale - reserved.left - reserved.right
	local usable_h = monitor.height / monitor.scale - reserved.top - reserved.bottom

	-- Clamped, not scaled: a width chosen to sit under the app's own responsive breakpoint
	-- must not shrink with the monitor. On a display too narrow to honour it the column
	-- simply takes the whole width, which also keeps `left` from going negative.
	local function column_left(want)
		return px(math.max(0, usable_w - math.min(want, usable_w)))
	end

	local left = column_left(col.width)
	local expanded_left = col.expanded and column_left(col.expanded) or nil
	local x = px(reserved.left + left)
	local y = px(reserved.top)
	local w = px(usable_w - left)
	local h = px(usable_h)

	if w <= 0 or h <= 0 then
		return
	end

	-- Per column, not shared: one column's geometry coming back unchanged must not
	-- suppress the rebuild of the other. expanded_left is in the key too, or a monitor
	-- change that happens to leave the narrow column alone would skip rebuilding the
	-- fullscreen rule below and leave it pointing at the old display's width.
	local geom = string.format("%d %d %d %d %d %s", left, x, y, w, h, tostring(expanded_left))
	if geom == col.geom then
		return
	end
	col.geom = geom

	local workspace = "special:" .. col.name

	-- Rules have no remove(), so retire the previous set instead of stacking new ones.
	if col.rules then
		for _, rule in ipairs(col.rules) do
			rule:set_enabled(false)
		end
	end

	col.rules = {
		hl.workspace_rule({
			workspace = workspace,
			gaps_out = { top = 0, right = 0, bottom = 0, left = left },
			-- Lives here rather than with the other on_created_empty rules below: rules
			-- sharing a selector merge, so retiring the previous one above used to take
			-- the launch command with it the first time a layer or monitor event
			-- recomputed the geometry, and nothing re-added it for the rest of the session.
			on_created_empty = col.launch,
		}),

		hl.window_rule({
			name = col.name .. "-main",
			match = { workspace = workspace, class = col.class },
			border_size = 0,
			rounding = 0,
			no_blur = true,
		}),
	}

	-- Same trick the scratchpad uses in dropdown.lua: a second workspace rule with a
	-- fullscreen-state selector lets Hyprland swap the gaps itself, so neither the
	-- fullscreen keybind nor an event hook has to know this workspace exists.
	--
	-- f[N] indexes the same states as a window's `fullscreen` field: 0 none, 1 maximized,
	-- 2 fullscreen. So f[1] is SUPER+F, which fills the workspace *minus* gaps and is the
	-- only one this can work through. SUPER+SHIFT+F is f[2], a real fullscreen positioned
	-- against the raw monitor, which ignores workspace gaps entirely -- measured, it
	-- covers the whole 2580x1080 -- so it deliberately gets no rule and stays fullscreen.
	--
	-- Carries gaps_out only -- on_created_empty stays on the base rule above, and the two
	-- selectors differ, so they do not merge.
	if expanded_left then
		col.rules[#col.rules + 1] = hl.workspace_rule({
			workspace = string.format("s[1] n[s:%s] f[1]", workspace),
			gaps_out = { top = 0, right = 0, bottom = 0, left = expanded_left },
		})
	end

	if col.media_viewer then
		col.rules[#col.rules + 1] = hl.window_rule({
			name = col.name .. "-media-viewer",
			match = {
				workspace = workspace,
				initial_class = col.class,
				initial_title = col.media_viewer,
			},
			border_size = 0,
			rounding = 0,
			float = true,
			suppress_event = "fullscreen maximize",
			move = string.format("%d %d", x, y),
			size = string.format("%d %d", w, h),
		})
	end
end

local function fit_columns()
	for _, col in ipairs(columns) do
		fit_column(col)
	end
end

fit_columns()
hl.on("monitor.layout_changed", fit_columns)
hl.on("monitor.focused", fit_columns)
hl.on("layer.opened", fit_columns)
hl.on("layer.closed", fit_columns)