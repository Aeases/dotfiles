---@module 'hl'

-- Special-workspace toggles that carry their own entrance animation.
--
-- specialWorkspaceIn/Out are global leaves, not per-workspace ones, so whichever
-- toggle fired last used to decide how every other special workspace moved.
-- Each bind here re-asserts its own pair before dispatching, which makes the
-- animation a property of the workspace instead of a property of history.

local M = {}

-- Mirrors the declarative pair in hyprland.lua; keep the two in step.
M.DEFAULT = {
	["in"] = { speed = 3, bezier = "easeOutQuint", style = "slide top" },
	out = { speed = 2, bezier = "easeInOutCubic", style = "slide bottom" },
}

M.LEFT = {
	["in"] = { speed = 3, bezier = "easeOutQuint", style = "slide left" },
	out = { speed = 2, bezier = "easeInOutCubic", style = "slide right" },
}

M.RIGHT = {
	["in"] = { speed = 3, bezier = "easeOutQuint", style = "slide right" },
	out = { speed = 2, bezier = "easeInOutCubic", style = "slide left" },
}

M.WACKY = {
	["in"] = { enabled = true, speed = 2.5, bezier = "overshot" },
	out = { enabled = false, speed = 1, bezier = "emphasizedAccel" },
	flash = true,
}

local FLASH_PALETTE = {
	{ "rgba(FF0090FF)", "rgba(00E5FFFF)" },
	{ "rgba(00E5FFFF)", "rgba(6BFF00FF)" },
	{ "rgba(6BFF00FF)", "rgba(FFD000FF)" },
	{ "rgba(FFD000FF)", "rgba(EB459EFF)" },
	{ "rgba(EB459EFF)", "rgba(5865F2FF)" },
}
local FLASH_STEP_MS = 100

-- Bumped per flash so a second press cancels the first chase instead of letting
-- the old timer clear the border out from under the new one.
local flash_generation = 0

local flash_rules = {}

-- Built on first use, not at load: the last matching rule wins, and special.lua
-- is required from keys.lua, which runs before window_rules.lua and its `s[1]`
-- gradient. Creating them lazily puts them last unconditionally.
local function rules_for(workspace)
	if flash_rules[workspace] then
		return flash_rules[workspace]
	end

	local rules = {}
	for i, colors in ipairs(FLASH_PALETTE) do
		rules[i] = hl.window_rule({
			name = "flash " .. workspace .. " " .. i,
			match = { workspace = workspace },
			border_color = { colors = colors, angle = math.floor(360 * (i - 1) / #FLASH_PALETTE) },
			enabled = false,
		})
	end

	flash_rules[workspace] = rules
	return rules
end

-- Mirrors the declarative borderangle line in hyprland.lua.
local function restore_borderangle()
	hl.animation({ leaf = "borderangle", enabled = true, speed = 1, bezier = "emphasizedDecel" })
end

local function flash(workspace)
	local rules = rules_for(workspace)

	flash_generation = flash_generation + 1
	local generation, step = flash_generation, 1

	-- nil disables every one of them, which ends the flourish.
	local function show(index)
		for i, rule in ipairs(rules) do
			rule:set_enabled(i == index)
		end
		hl.exec_scheduled_prop_refresh_immediately()
	end

	-- borderangle is global, so the chase borrows it and hands it back at the end.
	hl.animation({ leaf = "borderangle", enabled = true, speed = FLASH_STEP_MS / 100, bezier = "linear" })
	show(step)

	local timer
	timer = hl.timer(function()
		step = step + 1

		if generation ~= flash_generation then
			timer:set_enabled(false)
			return
		end

		if step > #rules then
			timer:set_enabled(false)
			show(nil)
			restore_borderangle()
			return
		end

		show(step)
	end, { timeout = FLASH_STEP_MS, type = "repeat" })
end

local function apply(leaf, spec)
	hl.animation({
		leaf = leaf,
		enabled = spec.enabled ~= false,
		speed = spec.speed,
		bezier = spec.bezier,
		style = spec.style,
	})
end

-- name -> anim spec, recorded by M.toggle so a dismissal can send a workspace away
-- with the same pair it arrived with. Populated at config load, since keys.lua calls
-- M.toggle immediately to build each bind's closure.
local anims = {}

local function do_toggle(name, anim)
	anim = anim or M.DEFAULT

	local workspace = "special:" .. name

	apply("specialWorkspaceIn", anim["in"])
	apply("specialWorkspaceOut", anim.out)

	-- Animation edits land on the pending config. Without the flush the
	-- dispatch below can still animate with the previous pair, leaving every
	-- press one entrance behind.
	hl.exec_scheduled_prop_refresh_immediately()

	-- Read before the dispatch: the flourish belongs to the arrival, not to
	-- the press that sends it away again.
	local shown = hl.get_active_special_workspace()
	local opening = not (shown and shown.name == workspace)

	hl.dispatch(hl.dsp.workspace.toggle_special(name))

	if anim.flash and opening then
		flash(workspace)
	end
end

-- Send the visible special workspace away with the pair it arrived with.
-- anims[name] is nil for a workspace nothing here toggled open -- a stray
-- `movetoworkspacesilent special` -- and do_toggle falls back to M.DEFAULT.
local function dismiss(shown)
	local name = shown.name:match("^special:(.+)$")
	if name then
		do_toggle(name, anims[name])
	end
end

---Toggle a special workspace, pinning the animation it should arrive with.
---@param name string special workspace name, without the `special:` prefix
---@param anim? table in/out animation spec; defaults to M.DEFAULT
---@return function
function M.toggle(name, anim)
	anim = anim or M.DEFAULT
	anims[name] = anim

	return function()
		do_toggle(name, anim)
	end
end

---Toggle a special workspace, but treat *any* visible special workspace as the thing
---to close first: one key that always gets you back to the desktop underneath, even
---from a workspace with no bind of its own.
---@param name string special workspace name, without the `special:` prefix
---@param anim? table in/out animation spec; defaults to M.DEFAULT
---@return function
function M.toggle_or_dismiss(name, anim)
	anim = anim or M.DEFAULT
	anims[name] = anim

	return function()
		local shown = hl.get_active_special_workspace()
		if shown then
			dismiss(shown)
		else
			do_toggle(name, anim)
		end
	end
end

local function contains(window, pos)
	local at, size = window.at, window.size
	if not (at and size) then
		return false
	end
	return pos.x >= at.x and pos.x < at.x + size.x and pos.y >= at.y and pos.y < at.y + size.y
end

---Dismiss the visible special workspace when a press lands outside its windows.
---
---Bound non-consuming to a bare mouse button, so this runs on *every* press: the
---no-special-workspace bail has to stay first and cheap.
---
---Deliberately ignores layer surfaces. waybar reports keyboard interactivity 0 yet is
---clickable, and discover-overlay sits at layer 3 spanning the whole screen, so any
---"is the cursor over a layer" test either misses the bar or blocks dismissal
---everywhere. A press on waybar therefore dismisses too -- and still reaches waybar,
---because the bind passes the event through.
function M.dismiss_on_outside_click()
	local monitor = hl.get_monitor_at_cursor()
	if not monitor then
		return
	end

	local shown = hl.get_active_special_workspace(monitor.name)
	if not shown then
		return
	end

	local pos = hl.get_cursor_pos()
	if not pos then
		return
	end

	for _, window in ipairs(shown:get_windows() or {}) do
		if contains(window, pos) then
			return
		end
	end

	dismiss(shown)
end

return M
