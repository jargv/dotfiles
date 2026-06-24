local mapping = require("mapping")
local normal = mapping.buffer("n")

normal.u = { "-", remap = true }
vim.opt_local.bufhidden = "wipe"
vim.opt_local.buflisted = false
