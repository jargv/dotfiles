local mapping = {}

local function createMappingObject(mode, prefix)
  prefix = prefix or ""
  return setmetatable({}, {
    __index = function()
      return nil
    end,
    __newindex = function(map, key, val)
      local str = ""
      local config = {
        noremap=true
      }
      if type(val) == 'string' then
        str = val
      elseif type(val) == 'function' then
        config.callback = val
      else
        print(type(val))
        return
      end
      vim.api.nvim_set_keymap(mode, prefix..key, str, config)
    end
  })
end

function mapping.withPrefix(prefix)
  return createMappingObject("n", prefix)
end

function mapping.inMode(mode, prefix)
  return createMappingObject(mode, prefix)
end

return setmetatable(mapping, mapping)
