local function terminal_dir()
  local buf = vim.fn.bufnr("%")
  local dir = vim.b[buf].current_shell_dir
  if dir == nil then
    local bufname = vim.fn.bufname("%")
    dir = bufname:match("^%S*//(%S*)//%S*$") or vim.fn.expand("%:p")
  end
  dir = vim.fn.fnamemodify(dir, ":p:~")
  return dir
end

local function oil_dir()
  local oil_prefix = "oil://"
  local file = vim.fn.expand("%")
  return file:sub(#oil_prefix+1, #file)
end

return function()
  if vim.bo.buftype == "terminal" then
    return terminal_dir()
  end

  if vim.bo.filetype == "oil" then
    return oil_dir()
  end

  return vim.fn.expand("%:p:~:h")
end
