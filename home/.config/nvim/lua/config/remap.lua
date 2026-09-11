vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

local fuzz = require "config.fuzz"
vim.keymap.set("n", "<leader>pf", fuzz.find_sans_git, { desc = "Find files (excludes .gitignored, .git*)" })
vim.keymap.set("n", "<leader>pt", fuzz.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>pg", fuzz.live_grep,  { desc = "Live grep" })
vim.keymap.set("n", "<leader>fw", fuzz.grep_string, { desc = "Grep word under cursor" })
