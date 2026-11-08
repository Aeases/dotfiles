---@module 'hl'

-- layer rules
hl.layer_rule({
	match = { namespace = "match:namespace shell:background" },
	animation = "fade",
}) -- ¯\_(ツ)_/¯

hl.layer_rule({
	match = { namespace = "launcher|selection|hyprpicker|vicinae|waybar|python3|oculante|wayscriber|cyberhud" },
	no_anim = true,
})

hl.layer_rule({
	match = { namespace = "waybar" },
	blur = true,
})

hl.window_rule({
	match = { initial_class = "mpv" },
	float = true,
	decorate = true,
})

hl.layer_rule({
	match = { namespace = "vicinae" },
	blur = true,
	ignore_alpha = 0,
})

hl.layer_rule({
	match = { namespace = "psst" },
	blur = false,
	ignore_alpha = 0,
})

hl.window_rule({ match = { float = false }, no_shadow = true })

local kittyfloat = hl.window_rule({
	match = {
		class = "kitty",
	},
	float = 1,
})

kittyfloat:set_enabled(false)

hl.window_rule({ match = { initial_class = "org.gnome.NautilusPreviewer" }, no_initial_focus = true, float = 1 })

hl.window_rule({
	name = "float files",
	match = {
		class = "org.gnome.Nautilus",
	},
	-- float = true,
	scrolling_width = 0.4,
})

hl.window_rule({
	match = {
		class = "modrinth-app-wrapped|Minecraft.*",
	},
	scrolling_width = 0.8,
})

hl.window_rule({
	match = {
		initial_class = "org.localsend.localsend_app",
	},
	float = true,
	size = "478 608",
	animation = "gnomed",
	rounding = 20,
	center = 1,
	dim_around = 1,
	border_size = 0,
})

-- ######## Steam ########
hl.window_rule({
	name = "steam-dialogs",
	match = {
		initial_class = "^steam$",
		initial_title = "negative:^Steam$",
	},
	float = true,
	no_blur = true,
})

hl.window_rule({
	name = "steam-min-size",
	match = { class = "^steam$", float = true },
	min_size = { 400, 300 },
	no_blur = true,
})

hl.window_rule({
	name = "steam-no-blur",
	match = { class = "^steam$" },
	no_blur = true,
})

-- ######## Games ########
hl.window_rule({
	name = "game-content-type",
	match = {
		class = "^(.*steam_app.*|gamescope)$",
		title = "negative:^$",
	},
	content = "game",
})

-- Stage 2, appearance and behaviour.
hl.window_rule({
	name = "games",
	match = { content = "game" },

	animation = "gnomed",
	--border_size = 0,
	border_size = 3,
	--rounding = 0,
	no_blur = true,
	render_unfocused = false,
	no_follow_mouse = false,
	scrolling_width = 1.0,
	idle_inhibit = "focus",
	no_shortcuts_inhibit = true,
})

hl.window_rule({
	name = "game-helper-windows",
	match = {
		class = "^(.*steam_app.*)$",
		title = "^$",
	},
	float = true,
	center = true,
})

-- hl.on("window.fullscreen", function(w)
-- 	local ws = w and w.fullscreen == 0 and w.workspace
-- 	if not ws or ws.tiled_layout ~= "scrolling" then
-- 		return
-- 	end
-- 	hl.timer(function()
-- 		local cur = hl.get_active_window()
-- 		local col = cur and cur.address == w.address and type(cur.layout) == "table" and cur.layout.column
-- 		if not col or not col.index or col.index == 0 then
-- 			return
-- 		end
-- 		local total, start, seen = 0, 0, {}
-- 		for _, m in ipairs(hl.get_windows()) do
-- 			local c = not m.floating and m.workspace and m.workspace.name == ws.name and type(m.layout) == "table" and m.layout.column
-- 			if c and c.index and not seen[c.index] then
-- 				seen[c.index] = true
-- 				total = total + (c.width or 0)
-- 				start = start + (c.index < col.index and c.width or 0)
-- 			end
-- 		end
-- 		local offset = hl.get_scrolling_offset()
-- 		if offset and start > 0 and total - start < 0.99 then
-- 			hl.set_scrolling_offset(math.max(0, offset * (total - 1) / start))
-- 		end
-- 	end, { timeout = 60, type = "oneshot" })
-- end)

-- START TODO REPLACE
local function scrolling_columns(ws)
	local cols = {}
	for _, m in ipairs(hl.get_windows()) do
		local c = not m.floating
			and m.workspace
			and m.workspace.name == ws.name
			and type(m.layout) == "table"
			and m.layout.column
		if c and c.index then
			cols[c.index] = cols[c.index] or { width = c.width or 0, window = m }
		end
	end
	return cols
end

hl.on("window.fullscreen", function(w)
	if not w or w.fullscreen ~= 0 then
		return
	end

	local ws = w.workspace
	if not ws or ws.tiled_layout ~= "scrolling" then
		return
	end

	local addr = w.address

	hl.timer(function()
		pcall(function()
			local cur = hl.get_active_window()
			if not cur or cur.address ~= addr then
				return
			end

			local col = type(cur.layout) == "table" and cur.layout.column
			local cols = col and col.index and scrolling_columns(ws)
			if cols and col.index > 0 then
				local last, total, start = -1, 0, 0
				for i, c in pairs(cols) do
					last = math.max(last, i)
				end
				local starts = {}
				for i = 0, last do
					starts[i] = total
					total = total + (cols[i] and cols[i].width or 0)
				end
				start = starts[col.index] or 0

				-- view starts at this column (just fitted); empty space past the tape end?
				if total - start < 1 - 0.01 then
					local target = math.max(0, total - 1)
					local k = 0
					for i = 0, last do
						if cols[i] and starts[i] < target - 0.001 then
							k = i
						end
					end
					if cols[k] then
						hl.dispatch(hl.dsp.focus({ window = cols[k].window }))
					end
					if target > 0 and cols[last] then
						hl.dispatch(hl.dsp.focus({ window = cols[last].window }))
					end
				end
			end

			hl.dispatch(hl.dsp.focus({ window = cur }))
		end)
	end, { timeout = 60, type = "oneshot" })
end)
-- END TODO REPLACE




hl.window_rule({
	match = {
		initial_class = "chrome-nngceckbapebfimnlniiiahkandclblb-Default",
	},
	float = true,
	persistent_size = true,
	border_size = 0,
	animation = "gnomed",
})

hl.window_rule({
	name = "PictureInPicture",
	match = {
		initial_title = "(?i)^picture-in-picture$",
	},
	float = true,
	pin = true,
	move = { "monitor_w - window_w*1.05", "monitor_h - window_h*1.05" },
	persistent_size = true,
})

hl.window_rule({
	name = "corner-review",
	match = {
		initial_title = "^Corner Review$",
	},
	float = true,
	pin = true,
	size = "989 581",
	move = { "20", "50" },
})

-- windowrule = scrollmouse 3.0, initialClass:steam_app_3513350
hl.window_rule({ match = { initial_class = "steam_app_3513350" }, scroll_mouse = 6.0 })

hl.window_rule({
	name = "clipstudio-empty-title",
	match = {
		initial_class = "^clipstudiopaint.exe$",
		initial_title = "^$",
	},

	rounding = 0,
	border_size = 0,
	no_anim = true,
	stay_focused = true,
	no_shadow = true,
})

hl.window_rule({
	match = {
		initial_class = "anki",
		initial_title = "Edit|Edit Current",
	},
	float = 1,
	size = "787 609",
})

hl.window_rule({ match = { initial_class = "fr.handbrake.ghb" }, float = true })

hl.window_rule({
	name = "fake-fullscreen-windows",
	match = { fullscreen_state_client = 2 },
	suppress_event = "maximize",
})

-- Wechat Popup rules (wechat popup windows have a intialTitle of "wechat" whereas the main window is "Wechat")
hl.window_rule({
	match = {
		initial_title = "^(.*wechat.*)$",
	},
	tag = "+wechat_popup",
	no_blur = true,
	border_size = 0,
	no_shadow = true,
})

-- SMART GAPS
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, border_size = 0, rounding = 0 })
-- float on maximized workspace
hl.window_rule({
	match = {
		workspace = "f[0]",
	},
	float = true,
})

-- workspace 10 (SUPER + 0): windows opened there float
hl.window_rule({ name = "ws10-float", match = { workspace = "10" }, float = true })
local ws10_float_early = hl.window_rule({ name = "ws10-float-early", match = { class = ".*" }, float = true })
local function sync_ws10_float_early()
	ws10_float_early:set_enabled((hl.get_active_workspace() or {}).id == 10)
end
sync_ws10_float_early()
hl.on("workspace.active", sync_ws10_float_early)
hl.on("monitor.focused", sync_ws10_float_early)

-- Special Workspace appearance
hl.window_rule({
	name = "Special Workspace",
	match = {
		workspace = "s[1]",
	},
	rounding = 15,
	border_color = { colors = { "rgba(3AA99Fee)", "rgba(4385BEee)" }, angle = 45 },
	animation = "slide",
	border_size = 6,
})
-- Special Workspace specific options
hl.workspace_rule({ workspace = "s[1]", gaps_out = 30, no_rounding = false })

hl.workspace_rule({ workspace = "special:discord", gaps_out = { top = 40, right = 80, bottom = 40, left = 80 } })
hl.window_rule({
	match = { workspace = "special:discord" },
	border_color = { colors = { "rgba(5865F2ee)", "rgba(7289DAee)" }, angle = 0 },
	border_size = 8,
})

require("special_sidebar")

-- Make file portals, / file pickers / File properties nice
hl.window_rule({
	match = {
		initial_class = "^(.*org.gnome.Nautilus)$",
		initial_title = "negative:^(.*(Loading|Properties).*)$",
	},
	rounding = 20,
	no_shadow = false,
	border_size = 0,
	persistent_size = true,
	center = true,
})
--    this will probably break with a gnome upadte or soemthing
-- i also match the properties window as a file picker window so it looks nice when i open it.
-- Make file portal open nice
-- round the properties window, cus it looks ugly if u dont
hl.window_rule({ match = { initial_title = "^(.*Properties.*)$" }, rounding = 10 })

hl.window_rule({
	match = { initial_class = "hyprland-share-picker" },
	float = true,
	size = "700 580",
	center = true,
	dim_around = true,
	border_size = 0,
})

hl.window_rule({ match = { initial_title = "PT Activity" }, workspace = "special:ActivityHell" }) -- fuck packet tracer activity window
hl.window_rule({ match = { class = "PacketTracer" }, render_unfocused = true })
-- ^^^ Prevents lagging when main window is not on the current workspace

-- so the lyrics still scroll when spotify is not in view.
hl.window_rule({
	match = {
		workspace = "special:spotify",
		class = "Spotify",
	},
	render_unfocused = true,
})

hl.window_rule({
	name = "border_color_rgb_fdf",
	match = {
		title = "^(.*All Of Human History In One Hour.*)$",
	},
	border_color = { colors = { "rgb(FDFC47)", "rgb(24FE41)" }, angle = 45 },
})

-- cam
hl.window_rule({
	name = "guvcview-camera",
	match = {
		initial_class = "^guvcview$",
		initial_title = [[^Guvcview  \(.* fps\)$]],
	},
	keep_aspect_ratio = true,
	float = true,
	pin = true,
	pseudo = true,
	size = "692 389",
	move = { "monitor_w - window_w*1.2", "monitor_h - window_h*0.93" },
	border_color = "rgb(FDFC47) rgb(FDFC47)",
})

hl.window_rule({
	name = "guvcview-controls-to-scratchpad",

	match = {
		initial_class = "^guvcview$",
		initial_title = "^Guvcview$",
	},

	workspace = "special:scratchpad silent",
	no_initial_focus = true,
})

-- satty
hl.window_rule({
	match = {
		initial_title = "satty",
	},
	border_color = "rgb(FDFC47)",
	keep_aspect_ratio = true,
	no_shadow = true,
	no_anim = true,
	float = true,
	immediate = true,
})

hl.window_rule({
	match = {
		initial_class = "app.drey.EarTag",
	},
	float = true,
})

-- Pulls up the speical workspace for these apps if they are opened normally
hl.window_rule({
	match = { class = "vesktop" },
	workspace = "special:discord",
})

hl.window_rule({
	match = { class = "discord" },
	workspace = "special:discord",
})

hl.window_rule({
	match = { class = "discord", initial_title = "Discord Popout" },
	opacity = "0.65 0.65",
	no_blur = true,
})

hl.window_rule({
	match = { class = "org.telegram.desktop" },
	workspace = "special:telegram",
})

hl.window_rule({
	match = { class = "Beeper" },
	workspace = "special:beeper",
})

hl.window_rule({
	match = { class = "signal" },
	workspace = "special:signal",
})
-- If special workspace opened without any apps in; spawn the apps.

hl.workspace_rule({
	workspace = "special:scratchpad",
	on_created_empty = 'kitty --class="kitty-spawn" -o env=KITTY_SCRATCHPAD=1 -o env=POWERLEVEL9K_INSTANT_PROMPT=off',
})

hl.workspace_rule({
	workspace = "special:spotify",
	on_created_empty = "uwsm-app -- com.spotify.Client.desktop",
})

hl.workspace_rule({
	workspace = "special:discord",
	on_created_empty = "discord",
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	name = "godot game windows",
	match = {
		title = "^(.*(DEBUG).*)$",
	},

	border_size = 1,
	rounding = 0,
	no_blur = true,
	float = true,
	no_shadow = true,
	render_unfocused = true,
})

hl.window_rule({
	name = "blender file browser",
	match = {
		initial_title = "File Browser",
		initial_class = "blender",
	},
	persistent_size = true,
})

hl.window_rule({
	match = { title = "ControlWindow" },
	float = 1,
	move = { "monitor_w - window_w*1.05", "monitor_h - window_h*1.05" },
	persistent_size = true,
	rounding = 8,
	border_size = 0,
})

hl.window_rule({
	match = { title = "ColorWindow" },
	float = 1,
	move = { "monitor_w - window_w*2", "monitor_h - window_h*2.85" },
	size = "150 50",
	rounding = 16,
	border_size = 0,
})

hl.window_rule({
	match = { class = "flameshot" },

	no_anim = true,
	rounding = 0,
	border_size = 0,
	suppress_event = "fullscreen", -- spawns floating anyway
	float = true,
	pin = true,
	move = { "0", "0" },
	size = { "monitor_w", "monitor_h" },
})

hl.window_rule({
	match = { title = "im-emoji-picker" },

	no_focus = true,
})
