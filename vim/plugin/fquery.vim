"todo: operator . which searches for suffixes
"      commands (or support in results view?)
"map <leader>o :call <SID>fquery()<cr>

command! Fquery :call <SID>fquery()

let s:operatorChars = ['<space>', '!', '[', ']']
let s:charRanges = range(48, 58) + range(97,122) + range(65,90)
let s:searchChars = map(s:charRanges, 'nr2char(v:val)')
let s:searchChars += ['-', '_']

func! <SID>fquery()
   let s:selectedLine = -1
   let s:operatorLocations = [-1]
   let s:searchString = ''
   let s:viewAtBegin = winrestcmd()
   let s:targetWindow = winnr()
   let s:history = [s:getIndex()]
   call s:setupResultsWindow()
   call s:setupCommandWindow()
   call s:renderFiles()
   startinsert
   echo
endfunc

func! s:filterFiles()
  "figure out the most recent operator
  let opPoint = s:operatorLocations[-1]
  let operator = opPoint == -1 ? ' ' : s:searchString[opPoint]
  let argString = s:searchString[opPoint+1:]
  let isNot = 0
  let copyPoint = -1
  let doFilter = 0

  if operator == ' '
     let doFilter = 1
  endif

  if operator == '!'
    let isNot = 1
    let doFilter = 1
    let copyPoint = -1 * len(argString)
  endif

  "copy the files and operate on the new set
  if doFilter
    call add(s:history, copy(s:history[copyPoint]))
    let cmpOp = isNot ? '==' : '!='
    call filter(
          \s:history[-1],
          \" match(".
          \"v:val,".
          \"   '\\c".argString."') ".cmpOp." -1")
  endif
endfunc

func! <SID>exitFquery(restore)
   silent bw! FqueryResultsWindow FqueryCommandWindow
   if a:restore
      exe s:viewAtBegin
   endif
endfunc

func! s:setupCommonOptions()
   setlocal nohidden
   setlocal buftype=nofile
   setlocal bufhidden=hide
   setlocal noswapfile
   setlocal noerrorbells
   setlocal nowrap
   setlocal nospell
endfunc

func! s:setupResultsWindow()
   topleft 10vsplit FqueryResultsWindow
   let s:resultsWindowNr = winnr()
   call s:setupCommonOptions()
   setlocal number
   call s:resetMatches()
endfunc

func! s:setupCommandWindow()
   botright 1split FqueryCommandWindow
   let s:commandWindowNr = winnr()
   call s:setupCommonOptions()
   setlocal nonumber

   augroup FqueryAuto
      au!
      au InsertLeave <buffer> call <SID>exitFquery(1)
   augroup end
   map <buffer> <esc> :call <SID>exitFquery(1)<CR>

   for c in s:searchChars
      exec "inoremap <buffer> <silent> <expr> ".c." <SID>searchChar('".c."')"
   endfor

   for c in s:operatorChars
      exec "inoremap <buffer> <silent> <expr> ".c." <SID>operatorChar('".c."')"
   endfor

   inoremap <buffer> <silent> <bs> <C-R>=<SID>backspace()<CR>
   inoremap <buffer> <silent> <cr> <C-R>=<SID>enterKey()<CR>
   inoremap <buffer> <silent> <tab> <C-R>=<SID>tabKey(1)<CR>
   inoremap <buffer> <silent> <s-tab> <C-R>=<SID>tabKey(-1)<CR>
   set winfixheight
endfunc

func! <SID>searchChar(ch)
   return a:ch."=g:FqueryDoChar('".a:ch."')"
endfunc

func! <SID>operatorChar(ch)
   return a:ch."=FqueryDoOperator('".a:ch."')"
endfunc

func! <SID>backspace()
   return "=FqueryDoBackspace()"
endfunc

func! FqueryDoChar(ch)
   let s:searchString .= a:ch
   call s:filterFiles()
   return s:renderFiles()
endfunc

func! FqueryDoOperator(ch)
   if a:ch == ']'
     let search = s:searchString[s:operatorLocations[-1]+1:]
     let cdup = get(split(system('git rev-parse --show-cdup'), '\n'), 0, "")
     let fileList = s:history[-1]
     let fileList = map(copy(fileList), "cdup . v:val")
     call add(s:history, split(system(
           \"git grep --name-only --full-name '".search."' -- "
           \."'".join(fileList, "' '")."'"
           \), '\n'))
     call s:renderFiles()
   endif
   let s:searchString .= a:ch
   call add(s:operatorLocations, len(s:searchString) - 1)
   return ""
endfunc

func! FqueryDoBackspace()
   if !len(s:searchString) | return "" | endif
   let lastOp = s:searchString[s:operatorLocations[-1]]
   let inBrackets = lastOp == '['
   let delChar = getline('.')[-1:]
   if (index(s:searchChars, delChar) != -1 && !inBrackets) || delChar == ']'
     let s:searchString = s:searchString[:-2]
     let s:history = s:history[:-2]
   elseif index(s:operatorChars, delChar) != -1
     let s:searchString = s:searchString[:-2]
   endif
   if len(s:searchString) <= s:operatorLocations[-1]
     let s:operatorLocations = s:operatorLocations[:-2]
   endif
   call setline('.', getline('.')[:-2])
   return s:renderFiles()
endfunc

func! <SID>enterKey()
   let cdup = get(split(system('git rev-parse --show-cdup'), '\n'), 0, "")
   if s:selectedLine >= 0
      let targetfile = cdup.s:history[-1][s:selectedLine]
      call <SID>exitFquery(1)
      exe s:targetWindow."winc w"
      exe "edit ".targetfile
   else
      exe s:resultsWindowNr."winc w"
      0file
      /^\s*$/d "remove empty lines
      /^\[>.*<\]$/d "remove status line
      exec '%s/^\s*/'.escape(cdup, '/.')."/"
      normal gg
      call clearmatches()
      call <SID>exitFquery(0)
   endif
   stopinsert
   return ""
endfunc

func! <SID>tabKey(dir)
  let s:selectedLine += a:dir
  call s:renderFiles()
  return ""
endfunc

func! s:resetMatches()
   call clearmatches()
   let matchString = join(filter(split(s:searchString, '[ \/]'), "len(v:val)"), '\|')
   if len(s:searchString) > 0
     call matchadd('Identifier', '\c'.matchString)
   endif
   match Number /\[.*\]\|^->/
endfunc

func! s:getIndex()
   let files = split(system('git ls-tree --full-tree --name-only -r HEAD'), '\n')
   return files
endfunc

func! s:renderFiles()
   let winSize = winheight(s:resultsWindowNr) - 1
   let nDisplayed = min([winSize, len(s:history[-1])])

   let width = 0
   let files = s:history[-1]
   let trimmedFiles = []
   for i in range(nDisplayed)
      let file = files[i]
      let width = max([len(file)+2, width])
      let selectedSymbol = "->"
      if s:selectedLine == i
        let file = selectedSymbol . file
      else
        let file = repeat(' ', len(selectedSymbol)).file
      endif
      call add(trimmedFiles, file)
   endfor

   "let nEmpty = max([0, winSize - nDisplayed])
   "let trimmedFiles = repeat([""], nEmpty) + trimmedFiles

   let nMore = len(files) - nDisplayed
   if nMore
     let msg = '[> '.(nMore).' not shown | '.getcwd().' <]'
   else
     let msg = '[>'.getcwd().'<]'
   endif

   call add(trimmedFiles, msg)
   let width = max([width, len(msg)])

   exe s:resultsWindowNr."winc w"
   normal ggVG"_d
   call append(0, trimmedFiles)
   exe "vertical resize ". (width + 5)
   normal gg
   call s:resetMatches()
   exe s:commandWindowNr . "winc w"
   return ""
endfunc
