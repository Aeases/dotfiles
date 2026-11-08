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

-- window address -> position in its column when it was tabbed (1 = top)
local tab_rank = {}
-- window address -> width of its column when it was tabbed
local tab_width = {}

local function ungroup_to_column(w)
	local g, members = w.group, {}
	for i, m in ipairs(g.members) do
		members[i] = { win = m, index = i, rank = tab_rank[m.address] or (1000 + i) }
	end
	table.sort(members, function(a, b)
		return a.rank < b.rank
	end)
	local width = tab_width[w.address] or (type(w.layout) == "table" and w.layout.column and w.layout.column.width)
	for _, m in ipairs(members) do
		tab_rank[m.win.address], tab_width[m.win.address] = nil, nil
	end

	local col = w.layout.column.index
	hl.dispatch(hl.dsp.layout("inhibit_scroll true"))
	hl.dispatch(hl.dsp.group.active({ index = members[1].index }))
	hl.dispatch(hl.dsp.focus({ window = members[1].win }))
	for i = 2, #members do
		local m = members[i].win
		g:remove(m)
		hl.dispatch(hl.dsp.focus({ window = m }))
		for _ = col + 2, m.layout.column.index do
			hl.dispatch(hl.dsp.layout("swapcol l"))
		end
		hl.dispatch(hl.dsp.layout("consume_or_expel prev"))
	end
	g:remove(members[1].win) -- last member: the group becomes this window, in place
	hl.dispatch(hl.dsp.focus({ window = w }))
	if width then
		hl.dispatch(hl.dsp.layout("colresize " .. width)) -- the column was re-created at default width
	end
	hl.dispatch(hl.dsp.layout("inhibit_scroll false"))
end

local function column_to_group(col)
	local ranked, width = col.windows, col.width
	table.sort(ranked, function(a, b)
		return a.layout.index_in_column < b.layout.index_in_column
	end)
	for i, m in ipairs(ranked) do
		tab_rank[m.address], tab_width[m.address] = i, width
	end

	hl.dispatch(hl.dsp.group.toggle()) -- the focused window becomes the group (and its top tab)
	local w = hl.get_active_window()
	if not (w and w.group) then
		return
	end
	for _, other in ipairs(ranked) do
		if other.address ~= w.address then
			w.group:add(other)
		end
	end
	hl.dispatch(hl.dsp.focus({ window = w }))
	hl.dispatch(hl.dsp.layout("colresize " .. width)) -- the group starts at the default width
end

function M.toggle_column_tabs()
	local w = hl.get_active_window()
	if not w or w.floating then
		return
	end
	if w.group then
		return ungroup_to_column(w)
	end
	local col = type(w.layout) == "table" and w.layout.column
	if col and #col.windows >= 2 then
		column_to_group(col)
	end
end

return M
