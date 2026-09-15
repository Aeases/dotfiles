---@module 'hl'

-- layer rules
hl.layer_rule({
	match = { namespace = "match:namespace shell:background" },
	animation = "fade",
}) -- ¯\_(ツ)_/¯

local screenshare = {
	active = 0,
	confirmed = false,
	generation = 0,
}

local function set_privacy(on)
	-- setsid -f detaches so this never blocks Hyprland's main loop.
	os.execute("setsid -f /home/zane/.scripts/screenshare-privacy " .. (on and "on" or "off") .. " >/dev/null 2>&1")
end

hl.on("screenshare.state", function(started)
	local s = screenshare
	local was_zero = s.active == 0
	s.active = math.max(0, s.active + (started and 1 or -1))

	if was_zero and s.active > 0 then
		s.generation = s.generation + 1
		local my_gen = s.generation
		hl.timer(function()
			if my_gen == s.generation and s.active > 0 then
				s.confirmed = true
				set_privacy(true)
			end
		end, { timeout = 700, type = "oneshot" }) -- confirm
	elseif s.active == 0 and s.confirmed then
		s.generation = s.generation + 1
		local my_gen = s.generation
		hl.timer(function()
			if my_gen == s.generation and s.active == 0 then
				s.confirmed = false
				set_privacy(false)
			end
		end, { timeout = 500, type = "oneshot" }) -- Release
	end
end)

hl.layer_rule({
	match = { namespace = "launcher|selection|hyprpicker|vicinae|waybar|python3|oculante|wayscriber" },
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
	float = true,
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

hl.window_rule({
	name = "games",
	match = {
		class = "^(.*steam_app.*|gamescope)$",
	},
	animation = "gnomed",
	border_size = 0,
	rounding = 0,
	no_blur = true,
})

hl.window_rule({
	match = {
		initial_class = "steam",
		initial_title = "Friends List",
	},
	float = true,
})

hl.window_rule({
	match = {
		initial_class = "steam",
		initial_title = "Steam Settings",
	},
	float = true,
})

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
		initial_title = "Picture-in-picture",
	},
	float = true,
	pin = true,
	move = { "monitor_w - window_w*1.05", "monitor_h - window_h*1.05" },
	persistent_size = true,
})

-- windowrule = scrollmouse 3.0, initialClass:steam_app_3513350

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

-- windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.
-- todo: make this only activate on fullscreenstate 2 windows (fake fullscreen windows)

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
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, rounding = 0 })
-- float on maximized workspace
hl.window_rule({
	match = {
		workspace = "f[0]",
	},
	float = true,
})

-- hl.window_rule({
-- 	match = {
-- 		workspace = "f[1]",
-- 	},
-- 	float = true,
-- })
--
-- hl.window_rule({
-- 	match = {
-- 		workspace = "f[2]",
-- 	},
-- 	float = true,
-- })

-- hl.workspace_rule({ workspace = "4", decorate = false, no_shadow = true, gaps_in = 0, gaps_out = 0 })
-- hl.window_rule({ match = { workspace = "4" }, border_size = 0, rounding = 0, no_shadow = true })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0, rounding = 0 })

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

hl.workspace_rule({ workspace = "special:discord",
		gaps_out = { top = 40, right = 80, bottom = 40, left = 80 },
 })
hl.window_rule({match = {workspace = "special:discord"},
	border_color = { colors = { "rgba(5865F2ee)", "rgba(7289DAee)" }, angle = 0 },
	border_size = 8,
})

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

hl.window_rule({ match = { initial_title = "PT Activity" }, workspace = "special:ActivityHell" }) -- fuck packet tracer activity window
hl.window_rule({ match = { class = "PacketTracer" }, render_unfocused = true })
-- ^^^ Prevents lagging when main window is not on the current workspace

-- so the lyrics still scroll when spotify is not in view.
hl.window_rule({
	name = "render_unfocused_on",
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

-- No Screensharing
hl.window_rule({
	match = {
		title = "^(.*Bitwarden.*)$|^(.*Traveller Information.*)$|^(.*ATPI Profile.*)$",
	},
	no_screen_share = true,
})

hl.window_rule({
	match = {
		initial_class = "discord|org.telegram.desktop|Bitwarden",
	},
	no_screen_share = true,
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
	match = { class = "org.telegram.desktop" },
	workspace = "special:telegram",
})
-- If special workspace opened without any apps in; spawn the apps.

hl.workspace_rule({
	workspace = "special:scratchpad",
	on_created_empty = 'kitty --class="kitty-spawn" -o env=KITTY_SCRATCHPAD=1 -o env=POWERLEVEL9K_INSTANT_PROMPT=off',
})

hl.workspace_rule({
	workspace = "special:spotify",
	on_created_empty = "spotify",
})

hl.workspace_rule({
	workspace = "special:discord",
	on_created_empty = "discord",
})

hl.workspace_rule({
	workspace = "special:telegram",
	on_created_empty = "Telegram",
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
	--no_anim = true,
	no_shadow = true,
	--no_follow_mouse = true,
	render_unfocused = true,
	--no_focus = true,
})

hl.window_rule({
	name = "blender file browser",
	match = {
		initial_title = "File Browser",
		initial_class = "blender",
	},
	persistent_size = true,
})

-- hl.window_rule({
-- 	match = { initial_title = "Godot" },
-- 	immediate = true,
-- })

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
	fullscreen_state = "0 0",
	float = true,
	pin = true,
	move = { "0", "0" },
	size = { "monitor_w", "monitor_h" },
})

hl.window_rule({
	match = { title = "im-emoji-picker" },

	no_focus = true,
})