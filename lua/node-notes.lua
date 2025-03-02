local M = {}

M.meta = {
	desc = "Add notes to treesitter objects and nodes.",
}

-- TODO:
--	Sketch out some draft APIs and functional requirements for the plugin.
--	Think of the keymaps and functionality you need.
--	Look over how to open a floating window over the cursor position.
--	Look into how to interact with treesitter objects.
--	One more thing, how would you save notes for a prticular treesitter node. What place woudl the notes live in.

M.setup = function()
	-- do something
end

-- NOTE: Props to tjdevries for making life easier, adven-of-neovim series for the win.
local function create_floating_buffer(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.width or math.floor(vim.o.lines * 0.8)

	-- Calculate the position of the center of the window.
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - width) / 2)

	-- Create a buffer
	local buf = nil
	-- TODO: If handle the case where the object already has notes and open them in the buffer.
	buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer

	-- Define window configuration
	local win_config = {
		relative = "cursor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	-- Create the floating window.
	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

M.open_floating_notes_for_object = function()
	local floating_buffer = create_floating_buffer(nil)

	-- TODO: Do this once notes are in place.
	-- If notes exist for this object set the buffer with the lines. Will uncoment after I have something to store notes in place
	-- vim.api.nvim_buf_set_lines(flot.buf, 0, -1, false, fetched_lines)
end

return M
