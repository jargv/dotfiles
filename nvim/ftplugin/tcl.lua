local mapping = require("mapping")
local normal = mapping.buffer("n")

normal["<F6>"] = {
  function()
    return ':w<CR> :!gnome-terminal -x tclsh ./' .. vim.fn.expand("%:t") .. '&<CR><CR>'
  end,
  expr = true,
  remap = true,
}
normal["<S-F6>"] = { ":w<CR>:!gnome-terminal -x ~/config/scripts/rapidDev tclsh % &<CR>", remap = true }
