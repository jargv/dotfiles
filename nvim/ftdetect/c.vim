let s:isLinux = system('uname') == "Linux\n"
let s:isMac = !g:isLinux
if s:isMac
  au BufRead,BufNewFile *.cpp set filetype=cpp
  au BufRead,BufNewFile *.h set filetype=cpp
else
  au BufRead,BufNewFile *.[ch] set filetype=c
  au BufRead,BufNewFile *.cpp set filetype=cpp
  au BufRead,BufNewFile *.hpp set filetype=cpp
endif
