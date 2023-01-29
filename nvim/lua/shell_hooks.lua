local shell_hooks = {}

-- global shell_hook function
_G.shell_hook =  function(dir)
  if dir ~= nil then
    vim.o.statusline = vim.o.statusline
    vim.b.current_shell_dir = dir
  else
    vim.defer_fn(function()
      vim.cmd [[doautocmd User ShellCommandHappened]]
    end, 0)
  end
end

return shell_hooks
