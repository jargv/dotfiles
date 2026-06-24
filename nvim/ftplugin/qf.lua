local mapping = require("mapping")
local normal = mapping.buffer("n")

normal["<CR>"] = "<CR>"
vim.opt.wrap = true
vim.cmd "hi QuickFixLine gui=bold ctermbg=None guibg=None"
vim.opt_local.number = false
