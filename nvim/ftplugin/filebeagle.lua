vim.keymap.set("n", "u", "-", { buffer = true, remap = true })
vim.keymap.set("n", "e", ':exec ":!vidir ".FileBeagleStatusLineCurrentDirInfo() <cr><cr>R', { buffer = true, remap = true })
