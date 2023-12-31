return {
  -- new {{{1
  s('new', fmt([[
    cmake_minimum_required (VERSION 3.28 FATAL_ERROR)
    project ({} VERSION 0.0 LANGUAGES CXX)

    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_SCAN_FOR_MODULES YES)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)

    # executable
    add_executable({})

    target_sources({}
    PRIVATE
      main.cpp
    )

    target_sources({}
    PRIVATE
    FILE_SET CXX_MODULES
    FILES
      helper.cxx
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

  -- exe {{{1
  s('exe', fmt([[
    add_executable({})
    target_sources({}
    PRIVATE
      main.cpp
    )
    target_sources({}
    PRIVATE
    FILE_SET CXX_MODULES
    FILES
      helper.cxx
    )

  ]], {i(1), rep(1), rep(1)})),

  -- lib {{{1
  s('lib', fmt([[
    add_library({})
    target_sources({}
    PRIVATE
    FILE_SET CXX_MODULES
    FILES
      {}.cxx
    )

  ]], {i(1),rep(1), rep(1)})),


  ---}}}
}
