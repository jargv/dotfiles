" make this a list of roots and select the appropriate one per buffer
let s:xqyRoots =
         \[ "/home/jonathan/projects/moml/src/main/xquery",
         \  "/home/jonathan/projects/chWeb/src/main/xquery"
         \]

func! <SNR>findBestRoot()
   let dir = getcwd()
   for path in s:xqyRoots
      if match(dir, path) != -1
         return path
      endif
   endfor
   echom "Couldn't match any xqy root paths!"
   return "~/tmp"
endfunc

let b:xqyRoot = <SNR>findBestRoot()

"tabs
setlocal tabstop=2
setlocal shiftwidth=2
setlocal noexpandtab
setlocal smarttab

" consider putting ':' here as well so that namespaced functions are one
" word
"dashed words are still just single words
set iskeyword+=-

inoreab <buffer> <expr> let <SID>NewVar()
inoreab <buffer> fn declare function(){};k$F(i
inoreab <buffer> = <ESC>bilet <ESC>wi$<ESC>ea :=
inoreab <buffer> err let $_err := fn:error()
inoreab <buffer> cl let $_log := xdmp:log()<ESC>i=Eatchar()

imap <buffer> <expr> <SPACE> <SID>Space()

"map <leader>u :call FindDependancies() <CR>
"func! FindDependancies()
"  normal ve"fy
"  exec "vimgrep " . @f . "( " . b:xqyRoot . "/../**/*.xqy " . b:xqyRoot . "/../**/*.ixd"
"endfunc

let s:completing = 0
func! <SID>NewVar()
	let s:completing = 1
	return "let $ :=hhi=Eatchar()"
endfunc

func! <SID>Space()
	if s:completing
		let s:completing = 0
		return "ea "
	else
		return " "
	endif
endfunc

" imports
setlocal include=^\\s*import\\s*module\\s*namespace\\s*
setlocal includeexpr=GetFilenameOfModule(v:fname)

func! GetFilenameOfModule(modName)
   let importLine = getline(search("import module namespace " . a:modName, "wnb"))
   let relativePath = get(matchlist(importLine, '\s*at\s*"\([^"]*\)"'), 1, "")
   let relativeParts = split(relativePath, "/")
   let rootParts = split(b:xqyRoot, "/")
   while len(relativeParts) && len(rootParts) && relativeParts[0] == ".."
      let rootParts = rootParts[0:len(rootParts)-1]
      let relativeParts = relativeParts[1:len(relativeParts)]
   endwhile
   let absolutePath = join(rootParts + relativeParts, "/")
   if len(rootParts)
      let absolutePath = '/' . absolutePath
   endif
   return absolutePath
endfunc

func! CompleteXQY(findstart, base)
   if a:findstart
      " locate the start of the word
      let line = getline('.')
      let start = col('.') - 1
      " add 0-9 in this regex...
      while start > 0 && line[start - 1] =~ '[-_:a-zA-Z]'
         let start -= 1
      endwhile
      return start
   else
      let baseParts = split(a:base, ":")
      let module = get(baseParts, 0, "")

      let filePath = GetFilenameOfModule(module)

      let res = []
      if (filereadable(filePath)) | for line in readfile(filePath)
         let matches = matchlist(line, 'declare\s\+function\s\+\([a-zA-Z:]*\)\s*(\(.*\)')
         if len(matches) > 2
            let func = matches[1]
            let func = get(split(func, ':'), 1, func) "pull off the namespace if it's there
            let args = '(' . split(matches[2], '{')[0]
            let dict = {}
            let dict.word = module . ':' . func . args
            let dict.abbr = func
            let dict.dup  = 1
            let dict.menu = args
            call add(res, dict)
         endif
      endfor | else
         return []
      endif
      return res
   endif
endfun
setlocal omnifunc=CompleteXQY

inoremap <buffer> <expr> : ShouldCompleteXQY()
func! ShouldCompleteXQY()
   let line = getline('.')
   let start = col('.') - 1
   let i = start
   "Skip all of the word going backwards
   while i > 0 && line[i - 1] =~ "[-_a-zA-Z]"
      let i -= 1
   endwhile
   "if we didn't land on a dollar, we're looking at a namespace
   if line[i - 1] == '(' && i == start
      return "::)hi"
   elseif (line[start - 1] != '$' && line[start -1] !~ '\s')
      return ":\<C-X>\<C-O>"
   endif
   return ':'
endfunc

func! Eatchar()
   call getchar()
   return ''
endfunc

iabbr <buffer><silent><expr> import AutoImport()
func! AutoImport()
   if getline(".") == "import"
      return "import module namespace \\\=Eatchar()\<CR>"
   else
      return "import"
   endif
endfunc

func! CompleteImport(findstart, base)
   if a:findstart
      " locate the start of the word
      let line = getline('.')
      let start = col('.') - 1
      while start > 0 && line[start - 1] =~ '[-_a-zA-Z/]'
         let start -= 1
      endwhile
      return start
   else
      for file in split(glob(b:xqyRoot . '/**/*.xqy'), "\n")
         for line in readfile(file)
            if complete_check()
               return []
            endif
            let matches = matchlist(line, 'module\s*namespace\s*\(\w*\)\s*=\s*"\([^"]*\)"\s*;\s*$')
            if len(matches) > 2
               let module = matches[1]
               let url    = matches[2]
               let file   = file[len(b:xqyRoot) : len(file)]
               if module =~ '^' . a:base
                  let mod = {}
                  let mod.abbr = module
                  let mod.menu = file
                  let mod.word = module . " = \"" . url . "\" at \"" . file . "\";"
                  let mod.dup  = 1
                  let mod.icase = 1
                  call complete_add(mod)
                  break "dont continue scanning this file
               endif
            endif
         endfor
      endfor
      return []
   endif
endfunc
setlocal completefunc=CompleteImport


