return {
  -- new {{{1
  s('new', fmt([[
    cmake_minimum_required (VERSION 3.25 FATAL_ERROR)
    project ({} VERSION 0.0 LANGUAGES CXX)

    set(CMAKE_CXX_STANDARD 20)

    # executable
    add_executable({}
      main.cpp
    )

    target_compile_options({}
      PRIVATE
      -Wall -Wextra -Wuninitialized -Werror
      -Wno-unused-parameter -Wno-unused-function -Wno-unused-variable
      -ftemplate-backtrace-limit=0
    )
  ]], {
    i(1, "proj"),
    rep(1),
    rep(1),
  })),

  -- if {{{1
  s('if', fmt([[
    if({})
      {}
    endif()
  ]], {i(1), i(2)})),

  -- opt {{{1
  s('opt', fmta([[
    option(<>)
    if("${<>}}")
      add_compile_definitions(<>)
    endif()
  ]], {i(1), rep(1), rep(1)})),

  ---}}}
}
