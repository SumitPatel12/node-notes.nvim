vim.api.nvim_create_user_command("NodeNotes", function()
	require("node-notes").open_floating_notes_for_object()
end, {})
