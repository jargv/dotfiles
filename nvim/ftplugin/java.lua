-- Settings
vim.opt_local.indentkeys = "o,O,*<Return>,<CR>,{,}"
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.omnifunc = "javacomplete#Complete"
vim.opt.cindent = false
vim.opt.smartindent = false
vim.opt.autoindent = true

local config = {
  cmd = { "/bin/jdtls" },
  root_dir = vim.fs.dirname(vim.fs.find({ ".gradlew", ".git", "mvnw" }, { upward = true })[1]),
}
require("jdtls").start_or_attach(config)

local mapping = require("mapping")
local normalGlobal = mapping.inMode("n")

normalGlobal["<A-i>"] = function()
  require("jdtls").organize_imports()
end
