---@module 'hl'

local special = require("special")
local layout = require("layout")

-- Apps use launch_app() (defined in hyprland.lua); short-lived commands and scripts stay plain
-- exec_cmd.
hl.bind("SUPER + SHIFT +Return", launch_app("kitty --class=kitty-spawn"))
hl.bind("SUPER + Return", launch_app("kitty --single-instance"))
hl.bind("SUPER + C", hl.dsp.window.close())

hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("hyprpicker| wl-copy"))

-- bind = SUPER, W, exec, tofi-drun | xargs hyprctl dispatch exec --
hl.bind("SUPER + W", hl.dsp.exec_cmd("vicinae toggle"))

-- Launch Lock Screen
hl.bind(
	"SUPER + M",
	hl.dsp.exec_cmd("loginctl lock-session && pactl set-sink-mute alsa_output.pci-0000_c1_00.6.analog-stereo 1")
)

-- Actually shutdown
hl.bind(
	"SUPER + SHIFT + M",
	hl.dsp.exec_cmd("/home/zane/.scripts/lib/prompt.sh 'Are you sure you want to quit' && uwsm stop")
)

-- fullscreen (hide other windows)
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- full-fullscreen
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

--hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen_state({ internal = 2, client = -1, action = "toggle" }))
--workaround till PR#16896 is in release 
hl.bind("SUPER + ALT + F", function()
	local w = hl.get_active_window()
	if not w then
		return
	end
	if w.fullscreen == 0 then
		hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 2, client = -1, action = "set" }))
		return
	end
	local client = w.fullscreen_client
	hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0, action = "set" }))
	if client ~= 0 then
		hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = client, action = "set" }))
	end
end)
hl.bind("SUPER + ALT + SHIFT + F", hl.dsp.window.fullscreen_state({ internal = 3, client = 2, action = "toggle" }))
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("/home/zane/.scripts/camera.sh"))
hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd("/home/zane/.scripts/audio_sink.py"))

-- Wifi Manager
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("/home/zane/.scripts/networkmanager_dmenu"))

hl.bind("SUPER + ALT + H", hl.dsp.exec_cmd("/home/zane/.scripts/monitor-menu"))

local function toggle_pip()
	local pip
	for _, w in ipairs(hl.get_windows()) do
		if w.title == "Picture-in-Picture" then
			pip = w
			break
		end
	end
	if not pip then
		return
	end

	if pip.workspace and pip.workspace.name == "special:pip" then
		local prev = hl.get_active_window()
		local target = prev and prev.workspace and not prev.workspace.name:match("^special:") and prev.workspace
			or hl.get_active_workspace()
		hl.dispatch(hl.dsp.window.move({ window = pip, workspace = target.id, follow = false }))
		hl.dispatch(hl.dsp.window.pin({ window = pip, action = "set" }))
	else
		-- a pinned window lives on every workspace, so unpin before moving it
		hl.dispatch(hl.dsp.window.pin({ window = pip, action = "unset" }))
		hl.dispatch(hl.dsp.window.move({ window = pip, workspace = "special:pip", follow = false }))
	end
end
hl.bind("SUPER + SHIFT + P", toggle_pip)

-- Keybinds for master
hl.bind("SUPER + P", hl.dsp.window.pin())
hl.bind("SUPER + TAB", hl.dsp.layout("swapwithmaster master"))
hl.bind("SUPER + T", function()
	if layout.is_scrolling() then
		layout.toggle_column_tabs()
	else
		hl.dispatch(hl.dsp.layout("orientationcycle"))
	end
end)
hl.bind("SUPER + n", hl.dsp.layout("addmaster"))
hl.bind("SUPER + SHIFT + n", hl.dsp.layout("removemaster"))

--Generic
hl.bind("SUPER + V", hl.dsp.window.float())
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + G", hl.dsp.group.toggle())

-- Move focus with mainMod + hjkl
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))

-- Move Windows w/ mainMod + Shift + hjkl
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d", group_aware = true }))

-- resize Windows w/ mainMod + ALT + hjkl
-- hl.bind("SUPER + ALT + H", hl.dsp.resizeactive("-60 0"))
-- hl.bind("SUPER + ALT + L", hl.dsp.resizeactive("60 0"))
-- hl.bind("SUPER + ALT + K", hl.dsp.resizeactive("0 -60"))
-- hl.bind("SUPER + ALT + J", hl.dsp.resizeactive("0 60"))

-- Special workspace for each app for easy access (e.g. tab+d = discord)
hl.bind("MOD5 + S", special.toggle("spotify"))
hl.bind("MOD5 + D", special.toggle("discord", special.WACKY))
hl.bind("MOD5 + T", special.toggle("telegram", special.RIGHT))
hl.bind("MOD5 + B", special.toggle("beeper", special.RIGHT))
hl.bind("MOD5 + R", special.toggle("signal", special.RIGHT))
hl.bind("MOD5 + Q", launch_app("kitty"))
hl.bind("MOD5 + Z", launch_app("helium.desktop"))
hl.bind("MOD5 + E", launch_app("org.gnome.Nautilus.desktop"))

-- MOD5 is the iso-level3-shift / alt grave key, used on international keyboards
-- but i use it as another modifier key and bound it to holding down tab in keyd
hl.bind("SUPER + S", special.toggle_or_dismiss("scratchpad"))
hl.bind("SUPER + CTRL + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

hl.bind("mouse:272", special.dismiss_on_outside_click, { non_consuming = true })

-- Screenshot Keybind
hl.bind("PRINT", function()
	screenshot_privacy_lift()
	local mons = hl.get_monitors()
	table.sort(mons, function(a, b)
		return a.id < b.id
	end)
	for i, m in ipairs(mons) do
		if m.focused then
			hl.exec_cmd("flameshot screen -n " .. (i - 1) .. " -e")
			return
		end
	end
	hl.exec_cmd("flameshot gui")
end)
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd("/home/zane/.scripts/grimblast copy output --notify"))
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("/home/zane/.scripts/ocr-region"))

-- Audio keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("volumixer --toggle"))

-- Media Keys
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Keybind for just stopping spotify
hl.bind("SUPER + space", hl.dsp.exec_cmd("playerctl play-pause -p spotify"), { locked = true })

-- Brightness Keys
hl.bind("xf86monbrightnessup", hl.dsp.exec_cmd("brightnessctl set 10%+"))
hl.bind("xf86monbrightnessdown", hl.dsp.exec_cmd("brightnessctl set 10%-"))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + K", hl.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" }))

-- QE switch workspaces
hl.bind("SUPER + E", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + Q", hl.dsp.focus({ workspace = -1 }))

-- QE Focus Switching
hl.bind("SUPER + CTRL + Q", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + CTRL + E", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + SHIFT + Q", hl.dsp.layout("swapcol l"))
hl.bind("SUPER + SHIFT + E", hl.dsp.layout("swapcol r"))

-- uses move +col / -col specifically on scrolling workspaces
local function pan_or_focus(col, direction)
	return function()
		if layout.is_scrolling() then
			hl.dispatch(hl.dsp.layout("move " .. col))
		else
			hl.dispatch(hl.dsp.focus({ direction = direction }))
		end
	end
end

hl.bind("SUPER + A", pan_or_focus("-col", "left"))
hl.bind("SUPER + D", pan_or_focus("+col", "right"))

local function scrolling_msg(msg)
	return function()
		if layout.is_scrolling() then
			hl.dispatch(hl.dsp.layout(msg))
		end
	end
end

hl.bind("SUPER + R", scrolling_msg("colresize +conf"))
hl.bind("SUPER + SHIFT + A", scrolling_msg("consume_or_expel prev"))
hl.bind("SUPER + SHIFT + D", scrolling_msg("consume_or_expel next"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10
	hl.bind("SUPER" .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER" .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i }))
end

local function adjustZoom(operation)
	local current = hl.get_config("cursor.zoom_factor") or 1.0
	local new_zoom

	if operation == "in" then
		new_zoom = current * 1.25
	elseif operation == "out" then
		new_zoom = current / 1.25
	else
		new_zoom = 1.0
	end

	-- dont zoom out beyond min zoom
	if new_zoom < 1.0 then
		new_zoom = 1.0
	end

	hl.config({
		cursor = {
			zoom_factor = new_zoom,
		},
	})
end

-- Keybinds for increasing/decreasing zoom
hl.bind("SUPER + equal", function()
	adjustZoom("in")
end, { repeating = true, description = "Zoom In" })
hl.bind("SUPER + minus", function()
	adjustZoom("out")
end, { repeating = true, description = "Zoom Out" })
hl.bind("SUPER + SHIFT + minus", function()
	adjustZoom("reset")
end, { description = "Reset Zoom" })

hl.bind("SUPER + b", hl.dsp.exec_cmd("wayscriber --daemon-toggle"))

for _, key in ipairs({ "F13", "F14", "F15", "F16" }) do
	hl.bind(key, hl.dsp.pass({ window = "title:^ControlWindow$" }), { description = "Buzzer to ControlWindow" })
end
