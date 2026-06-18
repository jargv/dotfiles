return {
  -- for {{{1
  -- choiceNode with nested tabstops + mirrored loop var: needs lua.
  s("for", fmta([[
    for (<>){
      <>
    }
  ]], {
    c(1, {
      fmt("size_t {} = 0; {} < {}; {}++", {rep(2), i(2, "i"), i(1), rep(2)}),
      fmt("auto& {} : {}", {i(1, "item"), i(2, "items")}),
      fmt("auto {} : {}", {i(1, "item"), i(2, "items")}),
    }),
    i(0)
  })),

  -- l {{{1
  -- functionNode counts comma-separated args to build the "{} {} ..." format: needs lua.
  s('l', fmta([[
    LOG("<>: <>", <>);
  ]], {
    rep(1),
    f(function (args)
      local parts = vim.fn.split(args[1][1], "\\,")
      local sep = ""
      local res = ""
      for _ in ipairs(parts) do
        res = res .. sep .. "{}"
        sep = " "
      end
      return res
    end, {1}),
    i(1),
  })),

  --}}}
}
