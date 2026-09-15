-- Auto-mix screen-recorder files that carry desktop audio and mic audio as
-- two separate tracks (GPU Screen Recorder's Replay_*/Video_* output).
--
-- Only fires when the two audio tracks look like two halves of one recording:
-- same language (or none), no track titles, same channel count and rate. Real
-- multi-track releases (dual-language, commentary) are left alone.

local mp = require("mp")
local msg = require("mp.msg")

local DEFAULT_VOLUMES = { 1.0, 1.0 }
local LABELS = { "Desktop", "Mic" }

local state = nil -- { ids = {id1, id2}, volumes = {v1, v2}, enabled = bool }

local function graph()
	return string.format(
		"[aid%d]volume=%.2f[a1];[aid%d]volume=%.2f[a2];"
			.. "[a1][a2]amix=inputs=2:normalize=0:duration=longest:dropout_transition=0[ao]",
		state.ids[1],
		state.volumes[1],
		state.ids[2],
		state.volumes[2]
	)
end

local function apply()
	mp.set_property("lavfi-complex", graph())
end

local function adjust(which, delta)
	if not (state and state.enabled) then
		return
	end
	state.volumes[which] = math.min(2.0, math.max(0.0, state.volumes[which] + delta))
	apply()
	mp.osd_message(string.format("%s volume: %d%%", LABELS[which], state.volumes[which] * 100), 1)
end

local function toggle()
	if not state then
		return
	end
	if state.enabled then
		state.enabled = false
		mp.set_property("lavfi-complex", "")
		mp.set_property("aid", tostring(state.ids[1]))
		mp.osd_message("Track mixing off", 1)
	else
		state.enabled = true
		apply()
		mp.osd_message("Track mixing on", 1)
	end
end

local BINDINGS = {
	{ "1", "mix-desktop-up", function() adjust(1, 0.1) end },
	{ "Ctrl+1", "mix-desktop-down", function() adjust(1, -0.1) end },
	{ "2", "mix-mic-up", function() adjust(2, 0.1) end },
	{ "Ctrl+2", "mix-mic-down", function() adjust(2, -0.1) end },
	{ "Alt+m", "mix-toggle", toggle },
}

local bound = false

local function bind()
	if bound then
		return
	end
	for _, b in ipairs(BINDINGS) do
		mp.add_forced_key_binding(b[1], b[2], b[3])
	end
	bound = true
end

local function unbind()
	if not bound then
		return
	end
	for _, b in ipairs(BINDINGS) do
		mp.remove_key_binding(b[2])
	end
	bound = false
end

-- Two audio tracks that belong to the same recording rather than to a
-- multi-track release?
local function eligible(tracks)
	if #tracks ~= 2 then
		return false
	end
	local a, b = tracks[1], tracks[2]
	if a.external or b.external then
		return false
	end
	if a.title or b.title then
		return false
	end
	if a.lang ~= b.lang then
		return false
	end
	if a["demux-channel-count"] ~= b["demux-channel-count"] then
		return false
	end
	if a["demux-samplerate"] ~= b["demux-samplerate"] then
		return false
	end
	return true
end

mp.register_event("file-loaded", function()
	local tracks = {}
	for _, track in ipairs(mp.get_property_native("track-list") or {}) do
		if track.type == "audio" then
			tracks[#tracks + 1] = track
		end
	end

	if not eligible(tracks) then
		return
	end

	state = {
		ids = { tracks[1].id, tracks[2].id },
		volumes = { DEFAULT_VOLUMES[1], DEFAULT_VOLUMES[2] },
		enabled = true,
	}
	apply()
	bind()
	msg.info("mixing audio tracks " .. state.ids[1] .. " + " .. state.ids[2])
	mp.osd_message("Mixing desktop + mic audio", 1.5)
end)

mp.register_event("end-file", function()
	unbind()
	state = nil
end)
