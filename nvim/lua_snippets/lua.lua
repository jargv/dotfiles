return {
  -- snip {{{1
  -- dynamic codegen for lua-format snippets (counts {} to emit i(n) args): needs lua.
  s("snip",fmta("-- <> {{{1\ns('<>', fmt([[\n  <>\n]], {<>})),", {
    rep(1), i(1), i(2),
    f(function(args)
      local result = ""
      local sep = ""
      local i = 1
      for i,line in ipairs(args[1]) do
        for key,val in string.gmatch(line, "{}") do
          result = result .. sep .. ("i(%d),"):format(i)
          sep = " "
          i = i + 1
        end
      end
      return result
    end, {2})
  })),

  -- require {{{1
  -- functionNode derives the local name from the last dotted module component: needs lua.
  s('req', fmt([[
    local {} = require '{}'
  ]], {
    f(function(args)
      local parts = vim.fn.split(args[1][1], "\\.", true)
      return parts[#parts] or ""
    end, {1}),
    i(1)
  })),

  -- fn {{{1
  -- dynamicNode picks the function form based on the current line / name: needs lua.
  s('fn', {
    d(1, function()
      local line = vim.fn.getline('.')
      if line:match("%S") then
        return sn(nil, fmt([[
          function({})
            {}
          end
        ]], {i(1), i(2)}))
      else
        return sn(nil, fmt([[
          {}function{}({})
            {}
          end
        ]], {
          f(function (arg)
            local name = arg[1][1]
            if name:find(":") ~= nil or name:find("%.") ~= nil then
              return ""
            end
            return "local "
          end, {1}),
          i(1), i(2), i(3)
        }))
      end
    end)
  }),

  -- for {{{1
  -- choiceNode with nested tabstops (pairs/ipairs/numeric): needs lua.
  s('for', fmt([[
    for {} do
      {}
    end
  ]], {
    c(1, {
      fmt("{}, {} in pairs({})", {i(2, "key"), i(3, "val"), i(1, "items")}),
      fmt("{}, {} in ipairs({})", {i(2, "i"), i(3, "val"), i(1, "items")}),
      fmt("{} = {},{}", {i(3,"x"), i(2,"1"), i(1,"10")}),
    }),
    i(2),
  })),

  -- l {{{1
  -- functionNode expands comma-separated args into tostring(...) .. ',' .. ...: needs lua.
  s('l', fmt([[
  print("{}:" .. {})
  ]], {
    i(1),
    f(function (args)
      local parts = vim.fn.split(args[1][1], "\\,\\s*")
      local sep = ""
      local res = ""
      for _, val in ipairs(parts) do
        res = res .. sep .. "tostring(" .. val .. ")"
        sep = " .. ',' .. "
      end
      return res
    end, {1})
  })),

  --}}}
}
