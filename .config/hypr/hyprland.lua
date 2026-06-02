---@module 'hl'

-- Default
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1.25,
})

-- Internal Screen
hl.monitor({
	output = "desc:BOE 0x0BCA",
	mode = "2256x1504@59.99900",
	position = "auto",
	scale = 1.33,
})

-- AOC Monitor
hl.monitor({
	output = "desc:AOC U34G2G4R3 0x00002828",
	mode = "3440x1440@144",
	position = "auto",
	scale = 1.33,
})

-- --- Other Monitors ---

hl.monitor({
	output = "desc:Technical Concepts Ltd Beyond TV 0x00010000",
	mode = "preferred",
	position = "auto-up",
	scale = 1.67,
})

-- --- Workspaces ---

hl.workspace_rule({
	workspace = "1",
	monitor = "eDP-1",
})

hl.workspace_rule({
	workspace = "2",
	monitor = "eDP-1",
})

-- workspace = 1, layout:scrolling

-- Autostart
hl.on("hyprland.start", function()
	hl.exec_cmd("hyprpm reload")
	hl.exec_cmd("vicinae server")
	hl.exec_cmd("waybar")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("/lib/xdg-desktop-portal-gnome")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("waypaper --restore")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("kdeconnectd")
	-- Mute laptop speakers on boot
	hl.exec_cmd("sleep 4; pactl set-sink-mute 'alsa_output.pci-0000_c1_00.6.analog-stereo' 1")
	hl.exec_cmd("fcitx5")
	hl.exec_cmd(
		"uxplay -fps 60 -h265 -n Framesmith -vs waylandsink -restrict -allow 62:24:42:81:F0:2A -allow FE:01:6B:2F:36:7F -allow 66:03:56:B5:04:A0"
	)
	-- Allow casting to linux from ipad for discord screenshare ^^^^
	hl.exec_cmd("keyd-application-mapper -d")
	hl.exec_cmd("dex -a -s /etc/xdg/autostart/:~/.config/autostart/")
	hl.exec_cmd("steam -silent")
	hl.exec_cmd("grep -o \\w*$ /proc/acpi/button/lid/LID0/state| ~/.config/hypr/lid.sh")
end)
-- Exec (run every reload)
hl.on("config.reloaded", function()
	hl.exec_cmd("pkill waybar; waybar")
	-- Check laptop lid status on hyprland reload & startup.
	hl.exec_cmd("grep -o \\w*$ /proc/acpi/button/lid/LID0/state| ~/.config/hypr/lid.sh")
end)

-- exec-once = gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"   # for GTK4 apps

hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- env = XCURSOR_THEME,Adwaita
-- env = XCURSOR_SIZE,18
-- env = HYPRCURSOR_SIZE,32
-- env = HYPRCURSOR_THEME,aero
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")
hl.env("INPUT_METHOD", "fcitx")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")
hl.env("ILLOGICAL_IMPULSE_VIRTUAL_ENV", "~/.local/state/quickshell/.venv")

-- NVIDIA (not needed replaced by using switcherooctl)
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("NVD_BACKEND", "direct")
-- hl.env("__NV_PRIME_RENDER_OFFLOAD", 1)
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- ############ Others #############

-- Start Gnome desktop portal, it's only used for file picker
-- (specified in .config/xdg-desktop-portal/portals.conf)
--
local wallpaper = "${HOME}/.config/hypr/wallpapers/Final Fantasy VII.gif"

--exec-once = sleep 4; pactl set-sink-mute "alsa_output.pci-0000_c1_00.6.analog-stereo" 1

-- Clamshell Mode configuration
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("~/.config/hypr/lid.sh open"), { locked = true })
-- Lid is opened
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("~/.config/hypr/lid.sh close"), { locked = true })
-- Lid is closed

-- Set programs that you use
local terminal = "kitty --class=kitty-spawn"
local fileManager = "nautilus"
local menu = "tofi-drun| xargs hyprctl dispatch exec --"

hl.config({
	debug = {
		full_cm_proto = false,
		disable_logs = false,
		enable_stdout_logs = true,
	},
})

hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 5,
		border_size = 2,
		col = {
			active_border = "rgba(4385BEee)",
			inactive_border = "rgba(100F0Fee)",
		},
		resize_on_border = true,
		no_focus_fallback = false,
		layout = "master",
		allow_tearing = true,
	},
	input = {
		kb_layout = "us",
		follow_mouse = 1,
		focus_on_close = 1,
		special_fallthrough = true,
		touchpad = {
			natural_scroll = true,
			clickfinger_behavior = 1,
			-- tap-to-click = 0,
			disable_while_typing = 1,
			scroll_factor = 0.3,
		},
		force_no_accel = 1,
		sensitivity = -0.8,
		-- -1.0 to 1.0, 0 means no modification.
	},

	animations = {
		enabled = true,
	},

	xwayland = {
		force_zero_scaling = true,
		use_nearest_neighbor = false,
	},

	cursor = {
		sync_gsettings_theme = true,
	},

	scrolling = {
		fullscreen_on_one_column = true,
		column_width = 0.8,
		focus_fit_method = 1,
		follow_focus = true,
		follow_min_visible = 0,
		-- explicit_column_widths = { 0.25, 0.333, 0.5, 0.667, 0.75, 1.0 },
	},

	decoration = {
		rounding = 10,
		-- screen_shader = /home/zane/.config/hypr/shader.frag
		blur = {
			enabled = true,
			xray = false,
			special = false,
			new_optimizations = true,
			size = 3,
			passes = 3,
			brightness = 2,
			noise = 0.01,
			contrast = 1,
			popups = false,
			popups_ignorealpha = 0.6,
		},
		shadow = {
			enabled = true,
			range = 20,
			offset = "0 2",
			render_power = 4,
			color = "rgba(00000028)",
			color_inactive = "rgba(00000012)",
		},
	},
})

hl.config({
	render = {
		new_render_scheduling = false,
	},
})

hl.config({
	master = {
		new_on_top = true,
		-- new_status = master
		mfact = 0.50,
	},
})

hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.03, 0 }, { 0.8, 0.15 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "emphasizedDecel", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "emphasizedDecel", style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 1, bezier = "emphasizedDecel" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = false, speed = 5, bezier = "default" })
hl.animation({ leaf = "layers", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "overshot", style = "slidefadevert -50%" })
hl.animation({
	leaf = "specialWorkspaceOut",
	enabled = true,
	speed = 5,
	bezier = "overshot",
	style = "slidefadevert -50%",
})
hl.config({
	dwindle = {
		-- See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
		preserve_split = true,
		-- you probably want this
		smart_resizing = true,
	},
})

-- TODO:
--
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

hl.gesture({
	fingers = 3,
	direction = "down",
	scale = 3.5,
	action = "special",
	workspace_name = "scratchpad",
})

hl.config({
	gestures = {
		-- See https://wiki.hyprland.org/Configuring/Variables/ for more
		workspace_swipe_distance = 22,
		-- workspace_swipe_cancel_ratio = 0,
		workspace_swipe_min_speed_to_force = 10,
		-- workspace_swipe_forever = true
	},
})

hl.config({
	group = {
		insert_after_current = true,
		focus_removed_window = true,
		-- col.border_active = "0xffffffff",
		-- col.border_inactive = "0xffffffff",
		groupbar = {
			enabled = true,
			gradients = 1,
			render_titles = 1,
			text_offset = 1,
			height = 28,
			gradient_rounding = 16,
			gradient_rounding_power = 3.0,
			-- gradient_rounding = 0
			indicator_height = 0,
			indicator_gap = 0,
			keep_upper_gap = true,
			priority = 1,
			font_size = 16,
			font_family = "AdwaitaSans-Regular",
			gaps_in = 2,
			gaps_out = 6,
			text_color = "0xffeceff4",
			text_color_inactive = "0x44eceff4",
			-- col.active = "0xa0400f0f",
			-- col.inactive = "0x40ff00b0",
			blur = true,
		},
	},
})

hl.config({
	misc = {
		-- See https://wiki.hyprland.org/Configuring/Variables/ for more
		initial_workspace_tracking = 2,
		middle_click_paste = false,
		enable_anr_dialog = false, -- dont tell me when apps not responding i can tell
		render_unfocused_fps = 5,
		font_family = "Minecraft",
		enable_swallow = true,
		swallow_regex = "kitty|kitty-spawn",
		session_lock_xray = true,
		key_press_enables_dpms = true,
		allow_session_lock_restore = true,
		background_color = "0x100F0F",
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},
})

local hconf = "~/.config/hypr/"

require("keys")
require("window_rules")

hl.config({
	plugin = {
		hyprbars = {
			bar_height = 28,
			bar_color = "rgb(ececec)",
			col = { text = "rgb(1a1a1a)" },
			bar_text_size = 14,
			bar_padding = 10,
			bar_text_font = "Minecraft",
			bar_text_align = "left",
			bar_part_of_window = true,
			bar_precedence_over_border = true,
			inactive_button_color = "rgb(d1d1d1)",
		},
	},
})

-- Close (red)
hl.plugin.hyprbars.add_button({
	bg_color = "rgb(ff5f57)",
	fg_color = "rgb(000000)",
	size = 12,
	icon = "",
	action = "hyprctl dispatch killactive",
})

-- Minimize (yellow)
hl.plugin.hyprbars.add_button({
	bg_color = "rgb(febc2e)",
	fg_color = "rgb(000000)",
	size = 12,
	icon = "",
	action = "hyprctl dispatch movetoworkspacesilent special",
})

-- Maximize (green)
hl.plugin.hyprbars.add_button({
	bg_color = "rgb(28c840)",
	fg_color = "rgb(000000)",
	size = 12,
	icon = "",
	action = "hyprctl dispatch fullscreen 1",
})

-- sources
