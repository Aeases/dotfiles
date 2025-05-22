local mp = require("mp")

-- Define initial volumes for each audio track
local volumes = {
	[1] = 1.0, -- Audio track 1 instrumental
	[2] = 1.0, -- Audio track 2 lead vocal
}

-- Function to update the volume of a specific audio track
function updateVolume(track, delta)
	if volumes[track] then
		volumes[track] = math.min(2.0, math.max(0.0, volumes[track] + delta))
		mp.set_property(
			"lavfi-complex",
			"[aid1]volume="
				.. volumes[1]
				.. "[vol1];[aid2]volume="
				.. volumes[2]
				.. "[vol2];[vol1][vol2]amix=inputs=2:duration=first:dropout_transition=2[ao]"
		)
		mp.osd_message("Audio Track " .. track .. " Volume: " .. volumes[track], 1)
	end
end

-- Register hotkeys to control audio track volumes
mp.add_key_binding("1", "adjust_volume_track1", function()
	updateVolume(1, 0.1)
end)
mp.add_key_binding("2", "adjust_volume_track2", function()
	updateVolume(2, 0.1)
end)
mp.add_key_binding("CTRL+1", "decrease_volume_track1", function()
	updateVolume(1, -0.1)
end)
mp.add_key_binding("CTRL+2", "decrease_volume_track2", function()
	updateVolume(2, -0.1)
end)
