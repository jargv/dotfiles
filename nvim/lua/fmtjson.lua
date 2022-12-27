local function stringify_into_table(val, indent, parts)
  local t = type(val)
  if t == "table" then
    local subindent = indent .. "  "
    if #val ~= 0 or next(val, nil) == nil then
      table.insert(parts, "[\n")
      for i, subval in ipairs(val) do
        table.insert(parts, subindent)
        stringify_into_table(subval, subindent, parts)
        if i == #val then
          table.insert(parts, "\n")
        else
          table.insert(parts, ",\n")
        end
      end
      table.insert(parts, indent .. "]")
    else
      table.insert(parts, "{\n")
      for key, subval in pairs(val) do
        local is_last = next(val, key) == nil
        table.insert(parts, subindent .. '"' .. tostring(key) .. '": ')
        stringify_into_table(subval, subindent, parts)
        if is_last then
          table.insert(parts, "\n")
        else
          table.insert(parts, ",\n")
        end
      end
      table.insert(parts, indent.."}")
    end
  elseif t == "number" then
    table.insert(parts, tostring(val))
  elseif t == "string" then
    table.insert(parts, '"'..val..'"')
  elseif t == "nil" then
    table.insert(parts, "nil")
  elseif val == true then
    table.insert(parts, "true")
  elseif val == false then
    table.insert(parts, "false")
  else
    error("can't stringify value of type "..t, 2)
  end
end

local function fmtjson(val)
  local parts = {}
  stringify_into_table(val, "", parts)
  return table.concat(parts)
end

return fmtjson
