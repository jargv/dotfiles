return {
  -- if
  s("if", fmta([[
    if (<>) {
      <>
    }
  ]], {i(1, "true"), i(0)})),

  -- For
  s("for", fmta([[
    for(<>){
      <>
    }
  ]], {
    c(1, {
      fmt("size_t {} = 0; {} < {}; {}++", {rep(2), i(2, "i"), i(1), rep(2)}),
      fmt("auto& {} : {}", {i(2, "item"), i(1, "items")}),
      fmt("auto {} : {}", {i(2, "item"), i(1, "items")}),
    }),
    i(0)
  }))
}
