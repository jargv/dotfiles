
nnoremap <leader>;t :GhcModTypeInsert<cr>
nnoremap <leader>;i :GhcModInfoPreview<cr>
nnoremap <leader>;I :GhcModInfo<cr>
nnoremap <tab> :GhcModType<cr>
nnoremap <leader><tab> :GhcModTypeClear<cr>

setlocal omnifunc=necoghc#omnifunc

" handle imports {{{1
   setlocal include=^import\\s*\\(qualified\\)\\?\\s*
   setlocal includeexpr=substitute(v:fname,'\\.','/','g').'.'
   setlocal suffixesadd=hs,lhs,hsc

"run haddock (not enabled) {{{1
"nnoremap <buffer> <Leader>d :call <SNR>HaddockDev()<CR>
func! <SNR>HaddockDev()
   let file = "/tmp/haddock/".substitute(expand("%:r"), '\/', '-', 'g').".html"
   exec ":!chrome ".file." &"
   let cmd = "haddock --html --odir=/tmp/haddock/ ".expand("%:p")
   call BrowserRefresh#SetAutoRefreshCommand(cmd)
   call BrowserRefresh#ToggleBrowserRefresh()
endfunc

"Add extensions suggested by ghc {{{1
nnoremap <buffer> <Leader>;x :call <SID>AddExtensions()<CR>
func! <SID>AddExtensions()
  let errors = system('ghc -e ":q" ' . expand('%'))
  let exts = []
  for word in split(errors)
      let match = matchlist(word, '^-X\(\w*\)$')
      if match != []
        call add(exts, match[1])
      endif
  endfor
  if len(exts)
      call append(0, join(map(exts, "'{-# Language '.v:val.' #-}'"), '|'))
  endif
endfunc
"}}}

"make imports explicit {{{1
nnoremap <buffer> <Leader>;e :call ExplicitImports()<CR>
func! ExplicitImports()
   call setline('.', getline('.').'()')
   :w
   let errors = system("ghc -e :q ".expand("%"))
   let results = []
   for line in split(errors, "\n")
      let str = matchstr(line, "‘.*’")
      if len(str) >= 2
         call add(results, str[3:-4])
      endif
   endfor
   let imports = []
   for res in results
      if index(imports, res) == -1
         call add(imports, res)
      endif
   endfor
   call setline('.', getline('.')[:-3]) "remove the ()
   call setline('.', getline('.').'('.join(imports, ", ").')')
endfunc

"ghc-mod integration(dead) {{{1
   "check if ghc-mod is installed {{{2
   "if !executable("ghc-mod")
   "   call input("ghc-mod needs to be installed!")
   "endif
   ""the import complete function{{{2
   "let s:getImportFromLine = '^\s*import\s*\%(qualified\)\?\s\+\([A-Za-z0-9\.]*\)'
   "func! GHCModCompleteImport(findstart, base)
   "   if a:findstart
   "      let justImport = '^\s*import\s*\%(qualified\)\?\s*$'
   "      let hasImport = 'import'
   "      let hasDots = '\.'
   "      let line = getline('.')
   "      if line =~ justImport
   "         return len(matchstr(line, justImport))
   "      elseif line =~ hasDots && line =~ hasImport
   "         return getpos('.')[2]
   "      else
   "         return -2
   "      endif
   "   else
   "      let line = getline('.')
   "      let results = split(system("ghc-mod list"), '\n')
   "      let pathLen = len(split(line, '\.', 1))
   "      let matches = matchlist(line, s:getImportFromLine)
   "      let stem = get(matches, 1, "")
   "      call filter(results, "v:val =~ stem")
   "      call map(results, "get(split(v:val, '\\.'), pathLen-1, '')")
   "      return results
   "   endif
   "endfunc
   "" the complete function{{{2
   "func! GHCModComplete(findstart, base)
   "   let isImport  = '^import'
   "   let line = getline('.')
   "   if line =~ isImport
   "      if a:findstart
   "         let start = col('.') - 1
   "         while start > 0 && line[start-1] =~ '\a'
   "            let start -= 1
   "         endwhile
   "         return start
   "      else
   "         let matches = matchlist(line, s:getImportFromLine)
   "         let module = get(matches, 1, "")
   "         if len(module)
   "            let results = split(system('ghc-mod browse -o '.module), '\n')
   "            let results = filter(results, 'v:val =~ "^".a:base')
   "            return results
   "         else
   "            return []
   "         endif
   "      endif
   "   else
   "      return -2
   "   endif
   "endfunc

   "set omnifunc=GHCModCompleteImport
   "set completefunc=GHCModComplete

   " Autocomplete mappings {{{1
   "noreab   <buffer> import import =EatChar()<CR>
   "noreab   <buffer> qualified qualified =EatChar()<CR>
   "inoremap <buffer> ( (
   "inoremap <buffer> , ,
   "inoremap <buffer> . .
   "inoremap        <buffer> <S-TAB> <C-P>
   "inoremap <expr> <buffer> <TAB> <SID>tab()

"utility functions
   "func! EatChar()
   "   call getchar()
   "   return ''
   "endfunc
