-- settings {{{1
vim.opt_local.list = false

local mapping = require("mapping")
local normal = mapping.buffer("n")
local insert = mapping.buffer("i")

insert["."] = "."

-- <leader>;j = join_vars {{{1
normal["<leader>;j"] = function()
  require("edit_helpers").join_vars()
end

-- <leader>;k = split_args {{{1
normal["<leader>;k"] = function()
  require("edit_helpers").split_args(true)
end

-- NOTE: dropped during migration --
--   the :GoInfo/:GoDoc/:GoDocBrowser/:GoLint/:GoRename/:GoMetaLinter/:GoImports/
--   gd->:GoDef maps (vim-go commands copy-pasted into this TypeScript ftplugin),
--   plus <leader>;ss / <leader>;sh (HighlightEmbedded) and <leader>;f
--   (:ToggleGoErrorFolding) -- all undefined here.
