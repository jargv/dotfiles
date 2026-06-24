vim.opt_local.errorformat = "%f:0(%l) : error C%n: %m"

vim.keymap.set("n", "<F3>", ":vsplit<CR>:e %:p:s,.vs$,.X123X,:s,.fs$,.vs,:s,.X123X$,.fs,<CR>", { buffer = true })
vim.keymap.set("i", "<F3>", "<ESC><F3>", { buffer = true })

vim.opt_local.iskeyword = "@,48-57,_,192-255"
vim.opt_local.commentstring = "// %s"
