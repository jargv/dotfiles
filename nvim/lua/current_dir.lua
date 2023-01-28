local function terminal_dir()
  local bufname = vim.fn.bufname("%")
  local dir = bufname:match("^%S*//(%S*)//%S*$") or vim.fn.expand("~:p")
  dir = vim.fn.fnamemodify(dir, ":p:~")
  return dir
end

return function()
  if vim.bo.buftype == "terminal" then
    return terminal_dir()
  end
  return vim.fn.expand("%:p:~:h")
end
