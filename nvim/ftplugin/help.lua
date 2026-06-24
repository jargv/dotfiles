local mapping = require("mapping")
local normal = mapping.buffer("n")

normal["<CR>"] = "<C-]>"
normal["<2-LeftMouse>"] = "<C-]>"

vim.opt_local.spell = false
vim.opt_local.foldmethod = "manual"
vim.opt_local.number = true
