
function setup_hyprbars()
	if hl.plugin.hyprbars ~= nil then
		-- Close (red)
		hl.plugin.hyprbars.add_button({
			bg_color = "rgb(ff5f57)",
			fg_color = "rgb(000000)",
			size = 12,
			icon = "",
			action = "hyprctl dispatch 'hl.dsp.window.kill(active)'",
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

		hl.config({
			plugin = {
				hyprbars = {
					bar_height = 28,
					bar_color = "rgb(282726)",
					col = { text = "rgb(CECDC3)" },
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
	end
end

setup_hyprbars()