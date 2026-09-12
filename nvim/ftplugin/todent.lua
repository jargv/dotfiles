
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.opt_local.foldtext = "v:lua.vim.lsp.foldtext()"
