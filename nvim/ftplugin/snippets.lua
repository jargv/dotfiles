function _G.SnipFoldExpr(lnum)
  if vim.fn.getline(lnum):match("^snippet") then
    return ">1"
  else
    return "="
  end
end

vim.opt_local.foldexpr = "v:lua.SnipFoldExpr(v:lnum)"
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldlevel = 0
vim.opt_local.expandtab = true
