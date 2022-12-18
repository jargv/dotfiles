return function()
  local package_names = {}
  for name in pairs(package.loaded) do
    table.insert(package_names, name)
  end

  for _,name in ipairs(package_names) do
    package.loaded[name] = nil
  end
end
