return {
  -- snippet {{{1
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
  s('req', fmt([[
    local {} = require '{}'
  ]], {
    f(function(args)
      local parts = vim.fn.split(args[1][1], "\\.", true)
      return parts[#parts] or ""
    end, {1}),
    i(1)
  })),

  -- lambda {{{1
  s('lm', fmt([[
    function({})
      {}
    end
  ]], {i(1), i(2)})),

  -- function {{{1
  s('fn', fmt([[
    {}function {}({})
      {}
    end
  ]], {
    f(function (arg)
      local name = arg[1][1]
      if name:find(":") ~= nil then
        return ""
      end
      return "local "
    end, {1}),
    i(1), i(2), i(0)
  })),

  -- for {{{1
  s('for', fmt([[
    for {} do
      {}
    end
  ]], {
    c(1, {
      fmt("{}, {} in pairs({})", {i(2, "key"), i(3, "val"), i(1, "items")}),
      fmt("{}, {} in ipairs({})", {i(2, "i"), i(3, "val"), i(1, "items")}),
      fmt("{} = {}..{}", {i(3,"x"), i(2,"1"), i(1,"10")}),
    }),
    i(2),
  })),

  -- if {{{1
  s('if', fmt([[
    if {} then
      {}
    end
  ]], {i(1), i(2)})),
  --}}}
}
