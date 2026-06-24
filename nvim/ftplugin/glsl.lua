local mapping = require("mapping")
local normal = mapping.buffer("n")
local insert = mapping.buffer("i")

vim.opt_local.errorformat = "%f:0(%l) : error C%n: %m"

normal["<F3>"] = ":vsplit<CR>:e %:p:s,.vs$,.X123X,:s,.fs$,.vs,:s,.X123X$,.fs,<CR>"
insert["<F3>"] = "<ESC><F3>"

vim.opt_local.iskeyword = "@,48-57,_,192-255"
vim.opt_local.commentstring = "// %s"
