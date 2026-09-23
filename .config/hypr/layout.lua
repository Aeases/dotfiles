---@module 'hl'

local M = {}

---@return HL.Workspace|nil
function M.target_workspace()
	local special = hl.get_active_special_workspace()
	if special then
		return special
	end

	local w = hl.get_active_window()
	return (w and w.workspace) or hl.get_active_workspace()
end

---@return boolean
function M.is_scrolling()
	local ws = M.target_workspace()
	return ws ~= nil and ws.tiled_layout == "scrolling"
end

return M
