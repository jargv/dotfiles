local mapping = require("mapping")
local normal = mapping.buffer("n")

normal["<esc>"] = ":NERDTreeClose<CR>"
normal["<leader>q"] = ":NERDTreeClose<CR>"
