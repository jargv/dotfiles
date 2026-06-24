local mapping = require("mapping")
local normal = mapping.buffer("n")

vim.opt.spell = true
normal["<Leader>g"] = { ":q!<CR>", remap = true }
