vim.g.maplocalleader = "t"

local mapping = require("mapping")
local allGlobal = mapping.inMode("")

allGlobal["<localleader>n"] = { "ggO", remap = true }
