local M = {}

M.meta = {
	desc = "Add notes to treesitter objects and nodes.",
}

local state = {}

-- TODO:
--	Sketch out some draft APIs and functional requirements for the plugin.
--	Think of the keymaps and functionality you need.
--	Look into how to interact with treesitter objects.
--	One more thing, how would you save notes for a prticular treesitter node. What place would the notes live in.

M.setup = function()
	-- do something
end

local function extract_lines_and_add_to_array(text)
	for line in vim.inspect(text):gmatch("[^\n]+") do
		table.insert(state, line)
	end
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

	-- Create the floating window.
	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

M.open_floating_notes_for_object = function()
	-- TODO: Wire up options if applicable.
	local current_buffer = vim.api.nvim_get_current_buf()
	local float = create_floating_buffer()

	-- TODO: Do this once notes are in place.
	-- If notes exist for this object set the buffer with the lines. Will uncoment after I have something to store notes in place
	vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, state)

	-- Set q to close the floating notes window.
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(float.win, true)
	end, {
		buffer = float.buf,
	})

	local restore = {
		cmdheight = {
			original = vim.o.cmdheight,
			present = 0,
		},
	}

	-- TODO: Look into how to show the mini status line for the floating window. This is so we can see if its in insert mode or not.
	-- Currently marking this as a nice to have. Potentially can use: https://github.com/windwp/windline.nvim
	for option, config in pairs(restore) do
		vim.opt[option] = config.present
	end

	-- NOTE: So scratch buffers do not support write. Non-scratch buffers would require a file name so scratch that(see what I did there).
	-- TODO:
	-- Save the contents of the buffer into our table or file before or when leaving the floating buffer.
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = float.buf,
		callback = function()
			-- OK so this does get me the contents now I've got to really think out the API and how to store these things.
			state = vim.api.nvim_buf_get_lines(float.buf, 0, -1, false)
			-- Restore options override.
			for option, config in pairs(restore) do
				vim.opt[option] = config.original
			end
		end,
	})
end

return M
