local M = {}

M.meta = {
	desc = "Add notes to treesitter objects and nodes.",
}

-- TODO:
--	Sketch out some draft APIs and functional requirements for the plugin.
--	Think of the keymaps and functionality you need.
--	Look into how to interact with treesitter objects.
--	One more thing, how would you save notes for a prticular treesitter node. What place would the notes live in.

M.setup = function()
	-- do something
end

-- NOTE: Props to tjdevries for making life easier, adven-of-neovim series for the win.
local function create_floating_buffer(opts)
	opts = opts or {}

	-- Create a buffer
	-- TODO: If handle the case where the object already has notes and open them in the buffer.
	-- Ok so am gonna use scratch buffer for now, will see where it takes me.
	local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer

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

	print(buf)
	-- Create the floating window.
	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

M.open_floating_notes_for_object = function()
	-- TODO: Wire up options if applicable.
	local float = create_floating_buffer()

	-- Set q to close the floating notes window.
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(float.win, true)
	end, {
		buffer = float.buf,
	})

	-- NOTE: So scratch buffers do not support write. Non-scratch buffers would require a file name so scratch that(see what I did there).
	-- vim.api.nvim_create_autocmd("BufWritePre", {
	-- 	buffer = float.buf,
	-- 	callback = function()
	-- 		print("floating window write called")
	-- 	end,
	-- })

	-- TODO: Save the contents of the buffer into our table or file before or when leaving the floating buffer.
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = float.buf,
		callback = function()
			-- OK so this does get me the contents now I've got to really think out the API and how to store these things.
			local current_contents = vim.api.nvim_buf_get_lines(float.buf, 0, -1, false)
			print(vim.inspect(current_contents))
		end,
	})

	-- TODO: Do this once notes are in place.
	-- If notes exist for this object set the buffer with the lines. Will uncoment after I have something to store notes in place
	-- vim.api.nvim_buf_set_lines(flot.buf, 0, -1, false, fetched_lines)
end

M.open_floating_notes_for_object()

return M
