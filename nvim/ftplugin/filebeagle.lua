local mapping = require("mapping")
local normal = mapping.buffer("n")

normal.u = { "-", remap = true }
normal.e = { ':exec ":!vidir ".FileBeagleStatusLineCurrentDirInfo() <cr><cr>R', remap = true }
