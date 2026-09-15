local share = 0.55

local covering = nil

local function cover(bottom)
	if covering == bottom then
		return
	end
	covering = bottom

	hl.workspace_rule({
		workspace = "special:scratchpad",
		gaps_in = 0,
		gaps_out = { top = 0, right = 0, bottom = bottom, left = 0 },
		no_rounding = true,

		no_border = true,
		layout = "scrolling",
	})

	hl.workspace_rule({
		workspace = "s[1] n[s:special:scratchpad] f[1]",
		gaps_out = { top = 0, right = 0, bottom = 134, left = 0 },
	})

	hl.window_rule({
		match = {
			workspace = "special:scratchpad",
			float = false,
		},
		scrolling_width = 1.0,
		rounding = 0,
		border_size = 0,
		no_shadow = true,
		--no_xdg_drags = true,
	})
end

local function fit()
	local monitor = hl.get_active_monitor()

	-- A monitor handle whose output has gone away answers nil to every field, and
	-- layout changes are exactly when that happens, so this also covers reading
	-- height and reserved below.
	if not monitor or not monitor.scale or monitor.scale <= 0 then
		return
	end

	-- Monitor dimensions are in physical pixels; gaps are logical, so the scale
	-- has to come out before the reserved area (already logical) comes off.
	local reserved = monitor.reserved
	local usable = monitor.height / monitor.scale - reserved.top - reserved.bottom

	cover(math.max(0, math.floor(usable * (1 - share))))
end


cover(0) -- default to covering the whole thing
fit() -- calculates cover amount then passes it to cover to update the window rules live

hl.on("monitor.layout_changed", fit) -- recalculate on layout change
hl.on("monitor.focused", fit) -- recalculate on monitor focus