vim.keymap.set("n", "<F6>", function()
  return ':w<CR> :!gnome-terminal -x tclsh ./' .. vim.fn.expand("%:t") .. '&<CR><CR>'
end, { buffer = true, expr = true, remap = true })
vim.keymap.set("n", "<S-F6>", ":w<CR>:!gnome-terminal -x ~/config/scripts/rapidDev tclsh % &<CR>", { buffer = true, remap = true })
