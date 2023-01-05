-- reset my modules only, so they are reloaded propery
return function()
  -- collect the output of local packages
  local module_dir = "ls ~/config/nvim/lua"
  local module_dir_ls = vim.fn.system(module_dir)
  if 0 ~= vim.api.nvim_get_vvar("shell_error") then
    print "error listing module directory"
    return
  end

  -- "unload" each package to ensure it's reloaded on next require
  for file in module_dir_ls:gmatch("[^\r\n]+") do
    local pkg_name = file:match("^(.*).lua")
    print(file)
    print(pkg_name)
    package.loaded[pkg_name] = nil
  end
end
