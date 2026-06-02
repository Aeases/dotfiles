---@module 'hl'

-- layer rules
hl.layer_rule({
	match = { namespace = "match:namespace shell:background" },
	animation = "fade",
}) -- ¯\_(ツ)_/¯

hl.layer_rule({
	match = { namespace = "swaync-notification-window" },
	no_screen_share = true,
})

hl.layer_rule({
	match = { namespace = "launcher|selection|hyprpicker|vicinae|waybar|python3|oculante" },
	no_anim = true,
})

hl.layer_rule({
	match = { namespace = "vicinae|waybar" },
	blur = true,
})

hl.workspace_rule({ workspace = "3", no_rounding = true, decorate = false })

-- no shadow on tiled windows
hl.window_rule({ match = { float = false }, no_shadow = true })

local kittyfloat = hl.window_rule({
	match = {
		class = "kitty",
	},
	float = 1,
})

kittyfloat:set_enabled(true)

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
		initial_class = "localsend",
	},
	float = true,
	size = "478 608",
	animation = "gnomed",
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
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0, rounding = 0 })

-- Special Workspace appearance
hl.window_rule({
	name = "Special Workspace",
	match = {
		workspace = "s[1]",
	},
	rounding = 15,
	border_color = { colors = { "rgba(f12711ee)", "rgba(f5af19ee)" }, angle = 0 },
	animation = "slide",
	border_size = 3,
})
-- Special Workspace specific options
hl.workspace_rule({ workspace = "s[1]", gaps_out = 15, no_rounding = false })

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
	match = {
		initial_class = "guvcview",
	},
	-- keep_aspect_ratio = true,
	pin = true,
	border_color = { colors = { "rgb(FDFC47)", "rgb(24FE41)" }, angle = 45 },
})

-- satty
hl.window_rule({
	match = {
		initial_title = "satty",
	},
	border_color = "rgb(FDFC47)",
	keep_aspect_ratio = true,
	no_shadow = true,
	animation = "fadeOut",
	no_anim = true,
	float = true,
	immediate = true,
})

-- No Screensharing
hl.window_rule({
	match = {
		initial_class = "org.telegram.desktop|Bitwarden",
		title = "^(.*Bitwarden.*)$|^(.*Traveller Information.*)$|^(.*ATPI Profile.*)$",
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
	on_created_empty = '[float; size 1000 800] kitty --class="kitty-spawn"',
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

-- no bars for everything
hl.window_rule({
	match = { initial_class = ".*" },
	["hyprbars:no_bar"] = true,
})

hl.window_rule({
	name = "godot game windows",
	match = {
		title = "^(.*(DEBUG).*)$",
	},
	border_size = 1,
	rounding = 0,
	no_blur = true,
	no_anim = true,
	no_shadow = true,
})

hl.window_rule({
	match = { initial_title = "Godot" },
	immediate = true,
})

-- only exception, has bars.
hl.window_rule({
	match = { title = "ControlWindow" },
	float = 1,
	["hyprbars:no_bar"] = false,
	move = { "monitor_w - window_w*1.05", "monitor_h - window_h*1.05" },
	persistent_size = true,
	rounding = 8,
	border_size = 2,
})
hl.window_rule({ match = { title = "ControlWindow", fullscreen = true }, ["hyprbars:no_bar"] = true })
