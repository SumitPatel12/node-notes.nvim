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

	-- Create a buffer
	local buf = nil
	-- TODO: If handle the case where the object already has notes and open them in the buffer.
	buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer

	-- TODO:
	-- Decide what all options need to be configurabel.
	-- Add some calcualtions to see where the floating window fits. There may be auto configs for it in the docs so check them out first.
	-- Define window configuration
	local win_config = {
		relative = "cursor",
		width = 50,
		height = 10,
		col = 0,
		row = 1,
		style = "minimal",
		border = "rounded",
	}

	-- Create the floating window.
	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

M.open_floating_notes_for_object = function()
	-- TODO: Wire up options if applicable.
	local floating_buffer = create_floating_buffer(nil)

	-- TODO: Do this once notes are in place.
	-- If notes exist for this object set the buffer with the lines. Will uncoment after I have something to store notes in place
	-- vim.api.nvim_buf_set_lines(flot.buf, 0, -1, false, fetched_lines)
end

create_floating_buffer(nil)

return M
