local mapping = require("mapping")
local normal = mapping.buffer("n")

normal["<leader><leader>"] = ":w<cr>"
normal["%"] = "o"
normal.q = ":q!<cr>"
