--- @since 26.1.22

local UUID_PATTERN = ("^(XXXXXXXX%-XXXX%-XXXX%-XXXX%-XXXXXXXXXXXX)(.*)$"):gsub("X", "%%x")

local M = {}

local config = {
	root = "inbee",
	file = "identities.txt",
	marker = "󰀄 ",
}

local identity_cache = {}

local function read_identities(path)
	local identities = {}
	local file = io.open(path, "r")
	if not file then
		return identities
	end

	for line in file:lines() do
		local id, name = line:match("^%s*(%S+)%s+(.-)%s*$")
		if id and name ~= "" and id:match(UUID_PATTERN) then
			identities[id:lower()] = name
		end
	end

	file:close()
	return identities
end

local function identities_in(dir)
	local path = dir .. "/" .. config.file
	if not identity_cache[path] then
		identity_cache[path] = read_identities(path)
	end
	return identity_cache[path]
end

local function find_root(dir)
	local escaped_root = config.root:gsub("%p", "%%%0")
	return (dir .. "/"):match("^(.*/" .. escaped_root .. ")/")
end

local function parent_of(dir)
	return dir:match("^(.*)/")
end

local function lookup_alias(dir, name)
	local id, suffix = name:match(UUID_PATTERN)
	if not id then
		return nil
	end

	local root = find_root(dir)
	if not root then
		return nil
	end

	local current = dir
	while true do
		local alias = identities_in(current)[id:lower()]
		if alias then
			return alias, suffix
		end
		if current == root then
			return nil
		end
		current = parent_of(current)
	end
end

local function translate_path(path)
	local walked = ""
	local translated = ""
	local changed = false

	for part in path:gmatch("[^/]+") do
		local alias, suffix = lookup_alias(walked, part)
		if alias then
			translated = translated .. "/" .. alias .. suffix
			changed = true
		else
			translated = translated .. "/" .. part
		end
		walked = walked .. "/" .. part
	end

	if changed then
		return translated
	end
end

local function patch_file_list()
	local original_highlights = Entity.highlights

	Entity.highlights = function(self)
		local file = self._file

		local search_highlights = file:highlights()
		if search_highlights and #search_highlights > 0 then
			return original_highlights(self)
		end

		local parent = tostring(file.url.parent or "")
		local alias, suffix = lookup_alias(parent, file.name)
		if not alias then
			return original_highlights(self)
		end

		return ui.Line {
			ui.Span(config.marker .. ui.printable(alias)):style(config.style),
			ui.printable(suffix),
		}
	end
end

local function patch_header()
	local original_cwd = Header.cwd

	Header.cwd = function(self)
		local translated = translate_path(tostring(self._current.cwd))
		if not translated then
			return original_cwd(self)
		end

		local max_width = self._area.w - self._right_width
		if max_width <= 0 then
			return ""
		end

		local text = ya.readable_path(translated) .. self:flags()
		return ui.Span(ui.truncate(text, { max = max_width, rtl = true })):style(th.mgr.cwd)
	end
end

function M:setup(opts)
	for key, value in pairs(opts or {}) do
		config[key] = value
	end
	config.style = config.style or ui.Style():fg("magenta"):italic()

	ps.sub("cd", function()
		identity_cache = {}
	end)

	patch_file_list()
	patch_header()
end

return M
