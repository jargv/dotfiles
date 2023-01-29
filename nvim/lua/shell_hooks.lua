--[[
TODO:
- make a user autocommand for every time a command happens
  - use it to update the status in gitato
  - use it to update the statusline (especially for terminals on cd)
CONSIDER:
- eliminate the callback interface and just do more inline here
]]
local shell_hooks = {}

local change_dir_hooks = {}
local cmd_happened_hooks = {}

function shell_hooks.on_command_happend(fn)
  table.insert(cmd_happened_hooks, fn)
end

function shell_hooks.on_change_directory(fn)
  table.insert(change_dir_hooks, fn)
end

-- global shell_hook function
_G.shell_hook =  function(dir)
  local hooks = dir ~= nil and change_dir_hooks or cmd_happened_hooks

  for _, hook in ipairs(hooks) do
    hook(dir)
  end
end

return shell_hooks
