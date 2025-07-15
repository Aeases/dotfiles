-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()
config.enable_wayland = true
config.warn_about_missing_glyphs = false
local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	local paneCurrProcess = basename(tab_info.active_pane.foreground_process_name)
	local paneCurrDir = tab_info.active_pane.current_working_dir.file_path
	-- local paneCurrDir = "/var/home/aeases/"
	local PathStringlen = string.len(paneCurrDir)
	local paneCD = string.sub(paneCurrDir, 0, PathStringlen - 1)
	return basename(paneCD) .. "「" .. paneCurrProcess .. "」"
end

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
	return tab.active_pane.title
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab_title(tab)
	local active_bg = "#279087"
	local active_fg = "#100F0F"
	local inactive_bg = "#1C1B1A"
	local inactive_fg = "#CECDC3"
	if tab.is_active then
		return wezterm.format({
			{ Foreground = { Color = active_bg } },
			{ Text = "" },
			"ResetAttributes",
			{ Background = { Color = active_bg } },
			{ Foreground = { Color = active_fg } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = "" .. title .. "" },
			"ResetAttributes",
			{ Foreground = { Color = active_bg } },
			{ Text = "" },
			"ResetAttributes",
		})
	else
		return wezterm.format({
			{ Foreground = { Color = inactive_bg } },
			{ Text = " " },
			"ResetAttributes",
			{ Background = { Color = inactive_bg } },
			{ Foreground = { Color = inactive_fg } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = title },
			"ResetAttributes",
			{ Foreground = { Color = inactive_bg } },
			{ Text = " " },
			"ResetAttributes",
		})
	end
	return title
end)

config.default_cursor_style = "BlinkingBar"
config.visual_bell = {
	fade_in_duration_ms = 150,
	fade_out_duration_ms = 150,

	--target = 'CursorColor',
}
config.text_blink_rapid_ease_out = "EaseInOut"
-- This is where you actually apply your config choices

-- For example, changing the color scheme:
--wezterm.color.load_scheme("/home/aeases/.config/wezterm/themes/flexoki-dark.toml")
config.color_scheme = "flexoki-dark"
local background_color = "#100F0F" --'#100F0F'
config.window_padding = {
	left = "0px",
	right = "0px",
	top = "1",
	bottom = "0px",
}

-- For Fancy tab bar
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 100
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.show_tab_index_in_tab_bar = false
config.adjust_window_size_when_changing_font_size = false
-- config.window_decorations = "RESIZE"
config.font_size = 14
config.font = wezterm.font_with_fallback({
	{ family = "M+1Code Nerd Font", weight = "Regular", italic = false },
	{ family = "Noto Sans SC", weight = "Regular", italic = false },
})
--config.font = wezterm.font_with_fallback {'Noto Sans Mono Medium', 'JetBrains Mono', 'M PLUS 2 Medium', 'DengXian' }
--config.font = wezterm.font_with_fallback {'JetBrains Mono', {family = 'M PLUS 1 Code', weight = 'Medium'}, 'DengXian'}
local f = "一回"
config.window_frame = {
	-- font = wezterm.font { family = 'Hack', weight = 'Bold' },
	font = wezterm.font_with_fallback({ "M+2 Nerd", "Hack", "DengXian" }),
	-- The size of the font in the tab bar.
	-- Default to 10.0 on Windows but 12.0 on other systems

	-- The overall background color of the tab bar when
	-- the window is focused
	active_titlebar_border_bottom = background_color,
	inactive_titlebar_border_bottom = background_color,
	-- The overall background color of the tab bar
	active_titlebar_bg = background_color,
	inactive_titlebar_bg = background_color,
}

--
config.colors = {
	visual_bell = "#FF2020",
	tab_bar = {
		inactive_tab_edge = background_color,

		-- The color of the strip that goes along the top of the window
		-- (does not apply when fancy tab bar is in use)
		background = background_color,
		-- The active tab is the one that has focus in the window
		active_tab = {
			-- The color of the background area for the tab
			bg_color = background_color,
			-- The color of the text for the tab
			fg_color = "#66800B",

			-- Specify whether you want "Half", "Normal" or "Bold" intensity for the
			-- label shown for this tab.
			-- The default is "Normal"
			intensity = "Normal",

			-- Specify whether you want "None", "Single" or "Double" underline for
			-- label shown for this tab.
			-- The default is "None"
			underline = "None",

			-- Specify whether you want the text to be italic (true) or not (false)
			-- for this tab.  The default is false.
			italic = false,

			-- Specify whether you want the text to be rendered with strikethrough (true)
			-- or not for this tab.  The default is false.
			strikethrough = false,
		},

		-- Inactive tabs are the tabs that do not have focus
		inactive_tab = {
			bg_color = background_color,
			fg_color = "#4385BE",

			-- The same options that were listed under the `active_tab` section above
			-- can also be used for `inactive_tab`.
		},

		-- You can configure some alternate styling when the mouse pointer
		-- moves over inactive tabs
		inactive_tab_hover = {
			bg_color = "#3b3052",
			fg_color = "#c0c0c0",

			-- The same options that were listed under the `active_tab` section above
			-- can also be used for `inactive_tab_hover`.
		},

		-- The new tab button that let you create new tabs
		new_tab = {
			bg_color = background_color,
			fg_color = "#c0c0c0",

			-- The same options that were listed under the `active_tab` section above
			-- can also be used for `new_tab`.
		},

		-- You can configure some alternate styling when the mouse pointer
		-- moves over the new tab button
		new_tab_hover = {
			bg_color = "#3b3052",
			fg_color = "#909090",
		},
	},
}

-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	Left = "h",
	Down = "j",
	Up = "k",
	Right = "l",
	-- reverse lookup
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

config.skip_close_confirmation_for_processes_named = {
	"bash",
	"sh",
	"zsh",
	"fish",
	"tmux",
	"nu",
	"cmd.exe",
	"pwsh.exe",
	"powershell.exe",
	"lf",
	"yazi",
}
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "NONE",
		action = wezterm.action.ScrollByLine(-3),
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "NONE",
		action = wezterm.action.ScrollByLine(3),
	},
}
config.leader = { key = "a", mods = "CTRL" }
config.disable_default_key_bindings = true
config.keys = {

	-- bashrc has the kill-backward commands now which covers us in most terminals. Should not be made specific to wezterm. The shortcuts are here incase needed in future.
	-- Use one of these
	-- { key = 'Backspace', mods = 'CTRL', action = act.SendKey {key = 'Backspace', mods = 'ALT'}
	-- most Linux shells use Alt + backspace instead for word backspace
	-- { key = 'Backspace', mods = 'CTRL', action = act.SendKey {key = 'w', mods = 'CTRL'},
	-- most Linux shells use Ctrl + w instead for word delete
	{ key = "Backspace", mods = "CTRL", action = wezterm.action.SendKey({ key = "Backspace", mods = "ALT" }) },
	{ key = "Backspace", mods = "CTRL", action = wezterm.action.SendKey({ key = "w", mods = "CTRL" }) },
	{ key = "a", mods = "LEADER|CTRL", action = wezterm.action({ SendString = "\x01" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "\\", mods = "LEADER", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{ key = "s", mods = "LEADER", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "v", mods = "LEADER", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	-- { key = "o", mods = "LEADER",       action="TogglePaneZoomState" },
	-- { key = "z", mods = "LEADER",       action="TogglePaneZoomState" },
	{ key = "f", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "t", mods = "LEADER", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
	-- move between split panes
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- { key = "h", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Left"}},
	-- { key = "j", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Down"}},
	-- { key = "k", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Up"}},
	-- { key = "l", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Right"}},
	-- resize panes
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
	{ key = "q", mods = "ALT", action = wezterm.action({ ActivateTabRelative = -1 }) },
	{ key = "e", mods = "ALT", action = wezterm.action({ ActivateTabRelative = 1 }) },
	{ key = "Enter", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
	{ key = "Enter", mods = "SUPER", action = wezterm.action.ActivateCopyMode },
	{ key = "H", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }) },
	{ key = "J", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }) },
	{ key = "K", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }) },
	{ key = "L", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }) },
	{ key = "1", mods = "LEADER", action = wezterm.action({ ActivateTab = 0 }) },
	{ key = "2", mods = "LEADER", action = wezterm.action({ ActivateTab = 1 }) },
	{ key = "3", mods = "LEADER", action = wezterm.action({ ActivateTab = 2 }) },
	{ key = "4", mods = "LEADER", action = wezterm.action({ ActivateTab = 3 }) },
	{ key = "5", mods = "LEADER", action = wezterm.action({ ActivateTab = 4 }) },
	{ key = "6", mods = "LEADER", action = wezterm.action({ ActivateTab = 5 }) },
	{ key = "7", mods = "LEADER", action = wezterm.action({ ActivateTab = 6 }) },
	{ key = "8", mods = "LEADER", action = wezterm.action({ ActivateTab = 7 }) },
	{ key = "9", mods = "LEADER", action = wezterm.action({ ActivateTab = 8 }) },
	{ key = "&", mods = "LEADER|SHIFT", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
	{ key = "d", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
	{ key = "c", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action({ CopyTo = "Clipboard" }) },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action({ PasteFrom = "Clipboard" }) },
	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
	{ key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
	{ key = "Enter", mods = "ALT", action = wezterm.action.ToggleFullScreen },
}
-- and finally, return the configuration to wezterm

return config
