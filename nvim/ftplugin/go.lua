-- settings {{{1
vim.opt_local.list = false

local mapping = require("mapping")
local normal = mapping.buffer("n")

-- <leader>;j = join_vars {{{1
normal["<leader>;j"] = function()
  require("edit_helpers").join_vars()
end

-- <leader>;k = split_args {{{1
normal["<leader>;k"] = function()
  require("edit_helpers").split_args(true)
end

-- NOTE: dropped during migration -- all referenced things that are not defined
-- anywhere in this config:
--   <leader>;ss / <leader>;sh -> HighlightEmbedded(...)  (undefined function)
--   <leader>;f               -> :ToggleGoErrorFolding    (undefined command)
-- and the long block of commented-out vim-go maps.
