local mapping = require("mapping")
local normal = mapping.buffer("n")

normal["<F6>"] = { ":!gnome-terminal -x scala % &<CR>", remap = true }
