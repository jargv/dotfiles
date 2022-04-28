if exists("current_compiler")
  finish
endif
let current_compiler = "ghc"

setlocal makeprg=nmake
setlocal errorformat&

setlocal makeprg=ghc\ -e\ :q\ %

let g:GHCFlags=""
command! -nargs=1 SetGHCFlags let g:GHCFlags="<args>" | exec "setlocal ".escape("makeprg=ghc <args> -e :q %", ' ')

setlocal errorformat=
                    \%-Z\ %#,
                    \%W%f:%l:%c:\ Warning:\ %m,
                    \%E%f:%l:%c:\ %m,
                    \%E%>%f:%l:%c:,
                    \%+C\ \ %#%m,
                    \%W%>%f:%l:%c:,
                    \%+C\ \ %#%tarning:\ %m,
