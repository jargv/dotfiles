"JavaComplete 2 {{{1
nnoremap <buffer> <leader>;i :JCimportAdd<cr>
nnoremap <buffer> <leader>;a :JCimportsAddMissing<cr>
nnoremap <buffer> <leader>;r :JCimportsRemoveUnused<cr>

"Settings {{{1
setlocal indentkeys=o,O,*<Return>,<CR>,{,}
setlocal shiftwidth=4 tabstop=4
setlocal omnifunc=javacomplete#Complete
set nocindent nosmartindent autoindent


"completion {{{1
inoremap <buffer> . .
setlocal completeopt=menu,menuone,preview,longest

"intellij integration {{{1
let s:file = "/tmp/intellij-vim-files"
nnoremap <buffer> <leader>;j :exec '!idea ' . expand("%:p") . " --line " . line('.')<cr><cr> |  |
nnoremap <buffer> <leader>;o :call <sid>openIntelliJFiles()<cr>

nnoremap <buffer> <leader>;; :e!<cr>

func! <sid>openIntelliJFiles()
  if !filereadable(s:file)
    echo "no files"
    return
  endif
   let files = readfile(s:file)
   let cmd = "tabe"
   for file in files
     exec cmd . " " . file
     let cmd = "vsplit"
   endfor
   exec "!rm ".s:file
endfunc
