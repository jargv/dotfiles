local mapping = require("mapping")
local allmodes = mapping.buffer("")

vim.opt.expandtab = true
allmodes["<F3>"] = { ':exec "vsplit ".expand(\'%:r\').".css"<cr>', remap = true }
