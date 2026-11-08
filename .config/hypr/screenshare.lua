---@module 'hl'

local PRIVATE, REVEALED = "share_private", "share_revealed"

for _, match in ipairs({
	{ title = "^(.*Bitwarden.*)$|^(.*Traveller Information.*)$|^(.*ATPI Profile.*)$" },
	{ initial_class = "com.microsoft.VSCode|discord|org.telegram.desktop|signal|Bitwarden|Beeper|md\\.obsidian\\.Obsidian" },
}) do
	hl.window_rule({ match = match, tag = "+" .. PRIVATE })
end

-- prevents reload erasing state
local state_file = ("%s/hypr/%s/screenshare-privacy"):format(
	os.getenv("XDG_RUNTIME_DIR") or "/tmp",
	os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or "default"
)
local s = { active = 0, shown = false, gen = 0 }
local f = io.open(state_file, "r")
if f then
	local active, shown = (f:read("*a") or ""):match("(%d+) (%d)")
	f:close()
	s.active, s.shown = tonumber(active) or 0, shown == "1"
end

local function save()
	local out = io.open(state_file, "w")
	if out then
		out:write(("%d %d\n"):format(s.active, s.shown and 1 or 0))
		out:close()
	end
end

local private = hl.window_rule({ match = { tag = PRIVATE }, no_screen_share = true })

-- styling

local mark = hl.window_rule({
	match = { tag = PRIVATE },
	border_color = "rgba(4385BEee) rgba(B16AF4ee) 45deg rgba(4385BE88) rgba(B16AF488) 45deg",
})
mark:set_enabled(s.shown)

hl.config({
	decoration = {
		glow = { enabled = true, color = "rgba(B16AF4e6)", color_inactive = "rgba(B16AF400)", range = 18, render_power = 2 },
	},
})
hl.window_rule({ match = { initial_class = ".*" }, no_glow = true })
hl.window_rule({
	match = { tag = REVEALED },
	no_screen_share = false,
	no_glow = false,
	border_color = "rgb(B16AF4) rgb(F472D0) 45deg rgb(6B3FA0)",
})

-- reveals a specific no_screen_share window during screenshare 
function screenshare_reveal(stable_id)
	hl.dispatch(hl.dsp.window.tag({ tag = REVEALED, window = "stableid:" .. tostring(stable_id) }))
end

-- activate screenshare privacy, but only if the screenshare lasts long enough
local function settle()
	s.gen = s.gen + 1
	local gen, want = s.gen, s.active > 0
	if want == s.shown then
		return
	end
	hl.timer(function()
		if gen ~= s.gen then
			return
		end
		s.shown = want
		save()
		hl.exec_cmd("/home/zane/.scripts/screenshare-privacy " .. (want and "on" or "off")) -- notifications, SSID
		mark:set_enabled(want)
		if not want then -- a reveal lasts one share
			for _, w in ipairs(hl.get_windows()) do
				hl.dispatch(hl.dsp.window.tag({ tag = "-" .. REVEALED, window = "stableid:" .. w.stable_id }))
			end
		end
	end, { timeout = want and 700 or 500, type = "oneshot" })
end

local function restore()
	s.lifted = nil
	private:set_enabled(true)
end

-- temp drop no_screen_share during a screenshot.
function screenshot_privacy_lift()
	local token = {}
	s.lifted, s.lift_starts = token, 0
	private:set_enabled(false)
	hl.timer(function()
		if s.lifted == token then
			restore()
		end
	end, { timeout = 3000, type = "oneshot" })
end

hl.on("screenshare.state", function(started)
	s.active = math.max(0, s.active + (started and 1 or -1))
	save()
	settle()
	if s.lifted then
		s.lift_starts = s.lift_starts + (started and 1 or 0)
		if not started or s.lift_starts > 1 then
			restore()
		end
	end
end)

settle() -- finish a toggle that a reload interrupted
