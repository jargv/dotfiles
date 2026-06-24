local mapping = require("mapping")
local normal = mapping.buffer("n")

vim.opt_local.tabstop = 2
vim.opt_local.foldmethod = "marker"
vim.opt.textwidth = 0

-- <Leader>;j: append " | J" at end of line, keep cursor put
local function join()
  local pos = vim.fn.getpos(".")
  vim.cmd("normal! A | J")
  vim.fn.setpos(".", pos)
end

normal["<Leader>;j"] = join
