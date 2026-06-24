vim.keymap.set("n", "<leader>m", "<c-j>", { remap = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  buffer = 0,
  callback = function()
    vim.fn.VrcQuery()
  end,
})
