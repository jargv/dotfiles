local shell_hooks = {}

-- global shell_hook function
vim.cmd [[
  function! ShellHook(...)
    if a:0 == 1
      let dir = a:1
      let &statusline = &statusline
      let b:current_shell_dir = dir
    else
      doautocmd User ShellCommandHappened
    endif
  endfunction
]]

return shell_hooks
