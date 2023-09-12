return {
  -- if {{{1
  s("if", fmta([[
    if (<>) {
      <>
    }
  ]], {i(1, "true"), i(0)})),

  -- for {{{1
  s("for", fmta([[
    for(<>){
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

  -- while {{{1
  s('while', fmta([[
    while (<>) {
      <>
    }
  ]], {i(1), i(0)})),
  -- fn {{{1
  s('fn', fmta([[
    auto <> = [<>](<>){
      <>
    };
  ]], {
    i(1),
    i(3),
    i(2),
    i(0),
  })),

  -- lm {{{1
  s('lm', fmta([[
    [<>](<>){
      <>
    }
  ]], {
    i(2),
    i(1),
    i(0),
  })),

  -- l {{{1
  s('l', fmt([[
    std::cout << "{}: " << {} << std::endl;
  ]], {
    i(1),
    f(function (args)
      local parts = vim.fn.split(args[1][1], "\\,")
      local sep = ""
      local res = ""
      for _, val in ipairs(parts) do
        res = res .. sep .. val
        sep = " << ',' << "
      end
      return res
    end, {1})
  })),

  -- log {{{1
  s('log', fmt([[
    std::cout << "{}" << std::endl;
  ]], {i(1)})),

}
