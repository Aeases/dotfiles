local bar_bg = "rgb(100F0F)"
local fg = "rgb(CECDC3)"
local dim = "rgb(575653)"

function setup_hyprbars()
	if hl.plugin.hyprbars ~= nil then
		-- Close
		hl.plugin.hyprbars.add_button({
			bg_color = "rgba(00000000)",
			fg_color = fg,
			size = 22,
			icon = "\u{F0156}", -- nf-md-close
			action = [[hyprctl dispatch 'hl.dsp.window.close()']],
		})

		-- Maximize
		hl.plugin.hyprbars.add_button({
			bg_color = "rgba(00000000)",
			fg_color = fg,
			size = 24,
			icon = "\u{F0143}", -- nf-md-chevron_up
			action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
		})

		-- Minimize
		hl.plugin.hyprbars.add_button({
			bg_color = "rgba(00000000)",
			fg_color = fg,
			size = 24,
			icon = "\u{F0140}", -- nf-md-chevron_down
			action = [[hyprctl dispatch 'hl.dsp.window.move({ workspace = "special", follow = false })']],
		})

		-- no bars for everything
		hl.window_rule({
			match = { initial_class = ".*" },
			["hyprbars:no_bar"] = true,
		})

		-- only exception, has bars.
		hl.window_rule({
			match = { title = "ControlWindow" },
			["hyprbars:no_bar"] = false,
		})

		-- other exception, has bars.
		hl.window_rule({
			match = { initial_class = "mpv" },
			["hyprbars:no_bar"] = false,
		})

		hl.window_rule({ match = { title = "ControlWindow", fullscreen = true }, ["hyprbars:no_bar"] = true })

		hl.window_rule({ match = { focus = false }, ["hyprbars:title_color"] = dim })

		hl.config({
			plugin = {
				hyprbars = {
					bar_height = 34,
					bar_color = bar_bg,
					col = { text = fg },
					bar_text_size = 16,
					bar_text_font = "Minecraft, JetBrainsMonoNL Nerd Font",
					bar_text_align = "left",
					bar_buttons_alignment = "right",
					bar_padding = 10,
					bar_button_padding = 2,
					bar_blur = true,
					bar_part_of_window = true,
					bar_precedence_over_border = true,
				},
			},
		})
	end
end

setup_hyprbars()