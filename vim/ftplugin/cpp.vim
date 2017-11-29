
" {{{ ycm
nnoremap <buffer> gd :YcmCompleter GoTo<cr>
nnoremap <buffer> gf :YcmCompleter GoToInclude<cr>
nnoremap <buffer> <leader>;i :YcmCompleter GetType<cr>
nnoremap <buffer> <leader>;I :YcmCompleter GetDoc<cr>
nnoremap <buffer> <leader>;; :YcmCompleter FixIt<cr>
nnoremap <buffer> <cr> :YcmCompleter GoToDeclaration<cr>

"better c++11 syntax support {{{1
let g:c_no_curly_error = 1
let g:c_no_bracket_error = 1

"swap header and source {{{1
nnoremap  <buffer> <leader>;h :w<CR>:e %:p:s,.hpp$,.X123X,:s,.cpp$,.hpp,:s,.X123X$,.cpp,<CR>

"general settings {{{1
set wildignore=*.o
set nospell

"<leader>;t: move out of header {{{1
if !exists("*MoveOutOfHeader")
   func! MoveOutOfHeader()
      let pattern = '^\s*\(class\|struct\)\s*\([A-Za-z_][A-Za-z0-9_]*\)'
      let pos = getpos('.')
      let col = pos[2]
      let lineNumber = pos[1]
      let line = getline('.')

      "get the class name
      let classStartLine = search(pattern, 'bWn')
      let className = get(matchlist(getline(classStartLine), pattern), 2, '')

      "figure out what the new definition
      if match(line, '^\s*friend') != -1
      let definitionHeader = substitute(line, 'friend\s*', '\1', '')
      else
      let definitionHeader = line[0:col-2] . className . '::' . line[col-1:]
      endif

      "figure out the new declaration
      call search('(')
      let [_, endCol] = searchpairpos('(', '', ')', 'Wn')

      let continueFindingCV = 1
      while continueFindingCV
        let continueFindingCV = 0
        for cv in ['&&', 'const', 'volatile', 'noexcept', 'final', 'override']
          let constStart = match(getline('.')[endCol : -1], cv)
          if constStart != -1
            let endCol += constStart + len(cv)
            let continueFindingCV = 1
          endif
        endfor
      endwhile
      let declaration = line[0:endCol-1] . ';'

      "find the body of the definition
      call setpos('.', pos)
      call search('{')
      let endline = searchpair('{', '', '}', 'Wn')

      "pull out the definition and unindent it
      let definition = getline(lineNumber+1, endline)
      let definition = [definitionHeader] + definition
      let spaces = match(definition[0], '\S')
      let definition = map(definition, "v:val[".spaces.":]")
      exec (lineNumber) . ',' . (endline) . 'd _'

      "put the declaration in
      call append(lineNumber-1, declaration)

      "add the definition to the cpp file
      :w | :e %:p:s,.hpp$,.X123X,:s,.cpp$,.hpp,:s,.X123X$,.cpp,
      call append(line('$'), '')
      call append(line('$'), definition)
      :w | :e %:p:s,.hpp$,.X123X,:s,.cpp$,.hpp,:s,.X123X$,.cpp,

      "restore the original position
      call setpos('.', pos)
   endfunc
endif
nnoremap <buffer> <leader>;t :call MoveOutOfHeader()<cr>

"remove std:: {{{1
nnoremap <buffer> <leader>;s :%s/std:://<cr>

"wrap block in lambda {{{1
nnoremap <buffer> <leader>;b :normal i[]()l%a();


"folding {{{1
setlocal foldnestmax=20
nnoremap <buffer> <leader>;f :set foldmethod=syntax<cr>
"convert lua to C++ {{{1
nnoremap <buffer> <leader>;L :call TranspileLua()<cr><cr>
vnoremap <buffer> <leader>;l :call TranspileLua()<cr><cr>
nnoremap <buffer> <leader>;l :0,$call TranspileLua()<cr><cr>
func! TranspileLua()
  let pos = getpos('.')
  s/local/auto/e
  s/elseif/} else if /e
  s/if\s*\(.*\)\s*then/if (\1){/e
  s/while\s*\(.*\)\s*then/while (\1){/e
  s/end/}/e
  s/function\s*(\(.*\))/[\&](\1){/e
  s/function\s*\([a-zA-Z0-9]*\)(\(.*\))/auto \1 = [\&](\2){/e
  s/function\s*\([^:\.]*\)\.method:\([^:]*\)(\(.*\))/auto \1::\2(\3){/e
  s/function\s*\([^:]*\):new(\(.*\))/\1::\1(\2){/e
  s/function\s*\([^:]*\):\([^:]*\)(\(.*\))/auto \1::\2(\3){/e
  s/for\s*_,\([^ ]*\)\s\+in\s\+ipairs(\(.*\))/for (auto\& \1 : \2)/e
  s/for\s\+\([^ ]*\)\s\+=\s\+\([^,]*\),\([^ ]*\)/for(auto \1 = \2; \1 < \3; ++\1)/e
  s/for\s\+\([^ ,]*\)\s*,\s*\([^ ]*\)\s\+in\s\+pairs(\([^)]*\))\s*do/for(auto\& pair : \3){auto\& \1 = pair.firstauto\& \2 = pair.second/e
  s/for\s\+\([^ ,]*\)\s*,\s*\([^ ]*\)\s\+in\s\+ipairs(\([^)]*\))\s*do/for(size_t _i = 0; _i < \3.size(); ++_i){auto \1 = _i+1auto\& \2 = \3[i]/e
  s/#\(\w*\)/\1.size()/e
  s/table\.insert(\([^,]*\),\s*\([^(]*\%(([^)]*)[^(]*\)*\))/\1.push_back(\2);/e
  s/\([A-Za-z0-9_]\+\):\([A-Za-z0-9_]\+\)/\1\.\2/e
  s/\~=/\!=/e
  s/self:/this->/e
  s/self\./this->/e
  s/\s*do\s*$/{/e
  s/--\[\[/\/\*/e
  s/--\]\]/\*\//e
  s/--/\/\//e
  s/\.\./+/e
  s/\<and\>/\&\&/e
  s/\<or\>/||/e
  s/\<nil\>/nullptr/e
  call setpos('.', pos)
endfunction

