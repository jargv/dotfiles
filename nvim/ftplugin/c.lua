local mapping = require("mapping")
local normal = mapping.buffer("n")

-- CppIndentCalc is defined (for now) in indent/c.vim
vim.opt_local.indentexpr = "CppIndentCalc(v:lnum)"
vim.opt_local.indentkeys = "o,O,*<Return>,<CR>,{,},:"

vim.g.c_no_curly_error = 1

normal["<leader>;h"] = ":w<CR>:e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<CR>"
