require("no-status"):setup()
require("smart-enter"):setup({
	open_multi = true,
})

require("relative-motions"):setup({
	show_numbers = "relative_absolute",
	line_numbers_styles = {
		hovered = ui.Style():bold():reverse(true),
		normal = ui.Style(),
	},
})
