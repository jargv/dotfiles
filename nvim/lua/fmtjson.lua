local function stringify_into_table(val, indent, parts, order)
  local t = type(val)
  if t == "table" then
    local subindent = indent .. "  "
    if #val ~= 0 or next(val, nil) == nil then
      table.insert(parts, "[\n")
      for i, subval in ipairs(val) do
        table.insert(parts, subindent)
        stringify_into_table(subval, subindent, parts, order)
        if i == #val then
          table.insert(parts, "\n")
        else
          table.insert(parts, ",\n")
        end
      end
      table.insert(parts, indent .. "]")
    else
      table.insert(parts, "{\n")
      -- `order` is an optional list of key names giving a partial ordering:
      -- listed keys come first in that order, the rest sort alphabetically.
      local rank = {}
      if order then
        for i, key in ipairs(order) do rank[key] = i end
      end
      local keys = {}
      for key in pairs(val) do table.insert(keys, key) end
      table.sort(keys, function(a, b)
        local ra, rb = rank[a], rank[b]
        if ra and rb then return ra < rb end
        if ra then return true end
        if rb then return false end
        return tostring(a) < tostring(b)
      end)
      for i, key in ipairs(keys) do
        table.insert(parts, subindent .. '"' .. tostring(key) .. '": ')
        stringify_into_table(val[key], subindent, parts, order)
        if i == #keys then
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

local function fmtjson(val, order)
  local parts = {}
  stringify_into_table(val, "", parts, order)
  return table.concat(parts)
end

return fmtjson
