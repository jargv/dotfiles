local mapping = require("mapping")
local allmodes = mapping.buffer("")

allmodes["<Leader>m"] = { ":silent !restview % <CR> <C-C>", remap = true }
