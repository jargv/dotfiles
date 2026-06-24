local mapping = {}

local function createMappingObject(mode, prefix, buffer)
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

      -- a table value carries the rhs in [1] plus extra opts:
      --   normal.gd = { "<Plug>(rust-def)", remap = true }
      --   insert["<S-TAB>"] = { shift_tab, expr = true }
      if type(val) == 'table' then
        for k, v in pairs(val) do
          if k ~= 1 then
            if k == 'remap' then
              config.noremap = not v
            else
              config[k] = v
            end
          end
        end
        val = val[1]
      end

      if type(val) == 'string' then
        str = val
      elseif type(val) == 'function' then
        config.callback = val
      else
        print(type(val))
        return
      end

      -- expr maps return keycodes like "<CR>"; translate them the way
      -- vim.keymap.set does by default
      if config.expr and config.replace_keycodes == nil then
        config.replace_keycodes = true
      end

      if buffer then
        vim.api.nvim_buf_set_keymap(0, mode, prefix..key, str, config)
      else
        vim.api.nvim_set_keymap(mode, prefix..key, str, config)
      end
    end
  })
end

function mapping.withPrefix(prefix)
  return createMappingObject("n", prefix)
end

function mapping.inMode(mode, prefix)
  return createMappingObject(mode, prefix)
end

-- buffer-local variant, for ftplugins
function mapping.buffer(mode, prefix)
  return createMappingObject(mode or "n", prefix, true)
end

return setmetatable(mapping, mapping)
