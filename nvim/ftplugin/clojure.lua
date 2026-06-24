vim.g["vimclojure#FuzzyIndent"] = 1
vim.g.maplocalleader = " ;"

vim.opt.lispwords:append("defpage")
vim.opt.lispwords:append("defproject")

-- don't do lispy identifiers
vim.opt_local.iskeyword = "@,48-57,_,192-255"
