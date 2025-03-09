-- TODO:
-- Need to cleanup the autocommand or find some other place to hook that in. As is it's causing mutliple subscriptions.
-- Look at hooking into the BufModifiedSet event so that the notes set operation does not need to be called unnecessarily.
-- Store the lnum in the state as well, this will be required when opening again and setting the signs.
local M = {}

M.meta = {
	desc = "Add notes to treesitter objects and nodes.",
}

--- @class notes.state
--- @field current_buffer number
--- @field buffer_notes table<string, table<string, string[]>>
--- @field current_win number
state = {
	current_win = 0,
	current_buffer = 0,
	current_buffer_file_path = nil,
	buffer_notes = {},
}

-- TODO:
--	Sketch out some draft APIs and functional requirements for the plugin.
--	Think of the keymaps and functionality you need.
--	Look into how to interact with treesitter objects.
--	One more thing, how would you save notes for a prticular treesitter node. What place would the notes live in.

M.signs = function()
	vim.fn.sign_define("sticky-note", { text = "", texthl = "StickyNote" })
end

M.setup = function()
	vim.keymap.set("n", "<leader>an", function()
		M.open_floating_notes_for_object()
	end)
	M.signs()
end

local function get_sign_id_at_cursor(lnum)
	-- NOTE: There should be only one sign per line for this group.

	--- @class vim.fn.sign_getplaced.ret.item[]
	local sign_items = vim.fn.sign_getplaced(state.current_buffer, {
		group = "sticky-notes-group",
		lnum = lnum,
	})

	-- As this is fetching for a single buffer there should only be one item in the returned list.
	-- If there are no signs we're gonna place one so return 0.
	if #sign_items == 0 or not sign_items[1].signs or #sign_items[1].signs == 0 then
		return 0
	end

	---@diagnostic disable-next-line: empty-block
	if #sign_items[1].signs ~= 1 then
		-- TODO: Raise some error or notification.
	end

	return sign_items[1].signs[1].id
end

local function populate_existing_notes_if_any(buf, lnum)
	local sign_id = get_sign_id_at_cursor(lnum)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, state.buffer_notes[state.current_buffer_file_path][sign_id] or { "" })
end

local function find_git_root()
	local path = vim.api.nvim_buf_get_name(state.current_buffer)

	while path and path ~= "/" do
		if vim.fn.isdirectory(path .. "/.git") == 1 then
			return path
		end
		path = vim.fn.fnamemodify(path, ":h")
	end

	return nil
end

local function place_sign_at_cursor(pos)
	local sign_id = vim.fn.sign_place(0, "sticky-notes-group", "sticky-note", state.current_buffer, { lnum = pos })
	return sign_id
end

-- NOTE: Props to tjdevries for making life easier, adven-of-neovim series for the win.
local function create_floating_buffer(opts)
	opts = opts or {}

	local buf = vim.api.nvim_create_buf(false, true)

	-- TODO:
	-- Decide what all options need to be configurabel.
	-- Add some calcualtions to see where the floating window fits. There may be auto configs for it in the docs so check them out first.
	-- Define window configuration

	--- @type vim.api.keyset.win_config
	local win_config = {
		relative = "cursor",
		width = 50,
		height = 10,
		col = 0,
		row = 1,
		style = "minimal",
		border = "rounded",
		-- The spaces at the start and the end are required for it to look aesthetically good. That's just a personal preference thought.
		title = " NODE NOTES ",
		title_pos = "center",
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

-- TODO: Clean this up if no longer required.
---@diagnostic disable-next-line: unused-local, unused-function
local function write_notes_to_file()
	local file_path = find_git_root() .. "/notes.json"
	local file, error = io.open(file_path, "w")
	if file then
		file:write(vim.json.encode(state.buffer_notes))
		file:close()
		print("Done writing notes to file.")
	else
		print("Error opening file." .. error)
	end
end

M.open_floating_notes_for_object = function()
	-- TODO: Wire up options if applicable.
	state.current_buffer = vim.api.nvim_get_current_buf()
	state.current_win = vim.api.nvim_get_current_win()
	local lnum = unpack(vim.api.nvim_win_get_cursor(0))
	state.current_buffer_file_path = vim.api.nvim_buf_get_name(0)

	local float = create_floating_buffer()

	if state.buffer_notes[state.current_buffer_file_path] == nil then
		state.buffer_notes[state.current_buffer_file_path] = {}
	end

	-- local ns = vim.api.nvim_create_namespace("node_notes")
	-- table.insert(state, "ns_id " .. ns .. " lnum " .. lnum .. " col " .. col)

	-- vim.api.nvim_buf_set_extmark(current_buffer, ns, lnum, col, {})

	-- local ext_mark = vim.api.nvim_buf_get_extmarks(current_buffer, ns, 0, -1, {})
	-- print(vim.inspect(ext_mark))

	-- table.insert(state, vim.inspect(ext_mark))

	populate_existing_notes_if_any(float.buf, lnum)

	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(float.win, true)
	end, {
		buffer = float.buf,
	})

	-- TODO: Look into how to show the lua status line in for the floating window.
	-- Currently marking this as a nice to have. Potentially can use: https://github.com/windwp/windline.nvim
	local restore = {
		cmdheight = {
			original = vim.o.cmdheight,
			present = 0,
		},
	}

	for option, config in pairs(restore) do
		vim.opt[option] = config.present
	end

	-- NOTE: So scratch buffers do not support write. Non-scratch buffers would require a file name so scratch that(see what I did there).
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = float.buf,
		callback = function()
			local notes = vim.api.nvim_buf_get_lines(float.buf, 0, -1, false)
			-- TODO: If notes are empty remove the sign.

			-- Try place sign if something was written
			local sign_id = place_sign_at_cursor(lnum)

			if sign_id == -1 then
				-- TODO: Chek how to raise a notofication.
			else
				state.buffer_notes[state.current_buffer_file_path][sign_id] = notes
			end

			-- Restore options override.
			for option, config in pairs(restore) do
				vim.opt[option] = config.original
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = state.current_buffer,
		-- TODO: Think whether or not I should just wire this up on all buffers and not just the current buffer.
		callback = function()
			--- @class vim.fn.sign_getplaced.ret.item[]
			local signs_items = vim.fn.sign_getplaced(state.current_buffer, { group = "sticky-notes-group" })
			-- local curent_buffer_notes = state.buffer_notes[state.current_buffer_file_path]

			-- Delete notes that do not match any sign.
			-- for key in pairs(curent_buffer_notes) do
			-- if not signs_items.signs[key] then
			-- curent_buffer_notes[key] = nil
			-- end
			-- end
		end,
	})
end

return M
