vim.api.nvim_create_user_command("Words", function()
	local words = require("512-words")

	words.open()
end, { desc = "A journal for your thoughts" })
