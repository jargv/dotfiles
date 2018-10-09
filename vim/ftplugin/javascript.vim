"trial settings {{{1

source ~/config/vim/ftplugin/html.vim

func! <SNR>FoldIndents()
    syntax region myFold start=/{/ end=/}/ transparent fold keepend extend
    setlocal foldmethod=syntax
    setlocal foldlevelstart=0
    setlocal foldlevel=0
    setlocal foldenable
    syn sync fromstart
    setlocal foldtext=<SNR>MyFoldText()
endfunc

function! <SNR>MyFoldText()
   let first = getline(v:foldstart)
   let last = substitute(getline(v:foldend), '^\s*', '', 'g')
   let lines = " <" . (v:foldend - v:foldstart) . " lines> "
   let first = substitute(first, '\.prototype\.', '::', 'e')
   let first = substitute(first, '\s*=\s*function', '', 'e')
   return first . lines . last
endfunction

" syntax match ProtoConceal "\.prototype\." conceal cchar=#
" setlocal conceallevel=1
" highlight link ProtoConceal Statement

"inoreab <buffer> fn function(){<CR>}<ESC>==k$hhh
"noreab <buffer> nfor <ESC>0wifor (var i=0; i<<ESC>A<BS>; i++){<CR>}<ESC>O
"noreab <buffer> afor <ESC>dBifor (var i=0, len=<ESC>pa.length; i<len; i++){<CR>}<ESC>Ovar = <C-R>"[i];<ESC>0ea

"tern {{{1
inoremap <buffer> . .
nnoremap <buffer> gd :TernDef<cr>
nnoremap <buffer> <leader>;i :TernType<cr>
nnoremap <buffer> <leader>;n :TernRename<cr>

"formatting/linting {{{1
augroup jsfmtlint
  autocmd!
  "autocmd BufWritePre *.js silent Neoformat
augroup END

setlocal indentexpr=
setlocal nosmartindent
setlocal nocindent
setlocal noautoindent
setlocal formatprg=standard\ --stdin\ --fix
setlocal indentkeys=o,O,*<Return>,<CR>,{,}

"toggle to corresponding css file (off) {{{1
"map <buffer> <leader>a :exec "vsplit ".expand('%:r').".css"<cr>

"utility functions {{{1
func! <SID>InCode()
   let syntaxId = synID(line('.'), col('.')-1, 0)
   let inNonCode = synIDattr(syntaxId, "name") =~? 'string\|comment'
   return !inNonCode
endfunc

func! EatChar()
   call getchar()
   return ''
endfunc

function! s:getVisualSelection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - 1]
  let lines[0] = lines[0][col1 - 1 :]
  return join(lines, "\n")
endfunction

" abbreviations (off) {{{1
" inoreabbr <buffer> if <C-R>=<SID>If()<CR>
"func! <SID>If()
"   if !<SID>InCode()
"      return "if"
"   endif
"
"   let line = getline('.')
"
"   if line =~ '^\s*$'
"      return "if (){\<CR>}\<ESC>kllla\<C-R>=EatChar()\<CR>"
"   elseif <SID>InCode() && line !~ "else" && line !~ '{'
"      return "\<C-O>Oif (){\<ESC>j>>o}\<ESC>kkllla\<C-R>=EatChar()\<CR>"
"   elseif line =~ "else"
"      return "if (){\<CR>}\<ESC>kf(a\<C-R>=EatChar()\<CR>"
"   elseif line =~ "{"
"      return "if ()\<ESC>ha\<C-R>=EatChar()\<CR>"
"   end
"endfunc
"
"ab cl console.log();hi<C-R>=EatChar()<CR>

" <Leader>;t: change a function's declaration style {{{1
nnoremap <buffer> <Leader>;t :call <SID>FlipHeaderType()<CR>
func! <SID>FlipHeaderType()
   let line = getline('.')
   if line =~ '\<var\>'
      s/^\(\s*\)var\s\+\(\w*\)\s*=\s*function(\([^)]*\))\s*{\s*$/\1function\ \2(\3){/e
   elseif line =~ '^\s*function'
      let pattern = '\s*function\s*\([A-Z]\w*\)'
      let savedscs = &scs  | set scs
      let ctorLine = search(pattern, 'bWn')
      let &scs = savedscs
      let ctorName = get(matchlist(getline(ctorLine), pattern), 1, '')
      if !empty(ctorName)
         exe 's/^\(\s*\)function\s\+\(\w*\)(\([^)]*\))\s*{\s*$/\1'.ctorName.'\.prototype\.\2\ =\ function(\3){/e'
      else
         s/^\(\s*\)function\s\+\(\w*\)(\([^)]*\))\s*{\s*$/\1var\ \2\ =\ function(\3){/e
      endif
   elseif line =~ '\.prototype\.'
      s/^\(\s*\)\w*\.prototype./\1var\ /e
   endif
   echo
endfunction

" <Leader>;w: wrap a block in { {{{1
vnoremap <buffer> <Leader>;w >'>o}'<O {hi

" <Leader>;u: unwrap a block {{{1
nnoremap <buffer> <Leader>;u m'vi{<'>jdd'<kdd`'k
" <Leader>;e: extract variable {{{1
vnoremap <buffer> <expr> <Leader>;e <SID>ExtractVariable()
func! <SID>ExtractVariable()
   let name  = input("name: ")
   return "c".name."\<ESC>Ovar ".name." = \<ESC>p`]a;\<ESC>"
endfunc
" <Leader>;f (visual): extract a function {{{1
vnoremap <buffer> <Leader>;f :call <SID>CreateFunction()<CR>
func! <SID>CreateFunction() range
   let input = input("name:")
   if input == ""
      normal! '<O(function(){
      normal! gv>
      normal! '>o})();
   else
      let [name;rest] = split(input, ' ')
      let params = join(rest, ', ')
      exe "normal! '<Ofunction ".name.'('.params.'){'
      normal! gv>
      exe "normal! '>o}\<CR>".name.'('.params.');'
   endif
endfunction

" <Leader>;f (normal) toggle a lambda from multi and single lined {{{1
nnoremap <buffer> <leader>;f :call <sid>toggleLambda()<cr>
func! <sid>toggleLambda()
  let line = getline('.')
  let pos = getcurpos()

  let multiline  = matchlist(line, '(\([^(]*\))\s*=>\s*{\s*$')
  if !len(multiline)
    return
  end
  let [_match, args; _rest] = multiline
  let nextLine = getline(line('.')+1)
  let closingLine = getline(line('.')+2)
  let body = substitute(nextLine, '^\s*', '', 'e')
  let body = substitute(body, '^return\s*', '', 'e')
  let closingParts = matchlist(closingLine, '^\s*}\(.*\)$')
  if !len(body) || !len(closingParts)
    return
  endif
  if match(args, ',') != -1 || len(args) == 0
    let args = '(' . args . ')'
  endif
  let closing = closingParts[1]
  if len(closing) && body[len(body)-1] == ';'
    let body = body[0:-2]
  endif
  let result = substitute(line, '([^()]*)\s*=>\s*{\s*$', args . ' => ' . body . closing, "")
  call setline('.', result)
  +1,+2delete _
  call setpos('.', pos)
endfunc

" <Leader>e load errors
nnoremap <buffer> <leader>e :call <sid>loadErrors()<cr>
func! <sid>loadErrors()
  :ALEDisable
  :ALEEnable
  :ALELint
  :ALEFix
  :lw
endfunc
