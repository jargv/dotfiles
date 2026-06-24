-- settings {{{1
vim.opt_local.list = false

vim.keymap.set("i", ".", ".", { buffer = true })

-- <leader>;j = join_vars {{{1
vim.keymap.set("n", "<leader>;j", function()
  require("edit_helpers").join_vars()
end, { buffer = true })

-- <leader>;k = split_args {{{1
vim.keymap.set("n", "<leader>;k", function()
  require("edit_helpers").split_args(true)
end, { buffer = true })

-- NOTE: dropped during migration --
--   the :GoInfo/:GoDoc/:GoDocBrowser/:GoLint/:GoRename/:GoMetaLinter/:GoImports/
--   gd->:GoDef maps (vim-go commands copy-pasted into this TypeScript ftplugin),
--   plus <leader>;ss / <leader>;sh (HighlightEmbedded) and <leader>;f
--   (:ToggleGoErrorFolding) -- all undefined here.
