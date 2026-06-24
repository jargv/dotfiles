vim.opt.expandtab = true
vim.keymap.set("", "<F3>", ':exec "vsplit ".expand(\'%:r\').".css"<cr>', { buffer = true, remap = true })
