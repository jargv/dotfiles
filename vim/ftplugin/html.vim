"toggle to corresponding js file {{{1
map <buffer> <F3> :exec "e ".expand('%:t:r').".js"<cr>

"tag wrapping {{{1
vnoremap <buffer> <Leader>;w :call <SID>WrapTag()<CR>
func! <SID>WrapTag() range
   let tagName = input("Tag name:")
   let pos = getpos('.')
   if a:firstline == a:lastline
      exe "normal! `>a</".tagName.">`<i<".tagName.">"
   else
      exe "normal! `>o</".tagName.">>>`<O<".tagName.">gv>"
   endif
   call setpos('.', pos)
endfunc

"change element name {{{1
nmap <buffer> <expr> <Leader>;t <SID>ChangeTag()
func! <SID>ChangeTag()
   let new = input("new tag name:")
   return "f>h%lciw".new."^lciw".new.""
endfunc


"dont do the underlines and bolds for link and strongs, etc. in html {{{1
let html_no_rendering=1

"remap K to work with long attributes{{{1
map <buffer> <leader>;k :call <sid>splitAttrs()<cr>
func! <sid>splitAttrs()
  let def = &gdefault
  set nogdefault

  let attr = '\v([-A-Za-z0-9_]+\="[^"]*")'
  let startline = line('.')
  s/\v([-A-Za-z0-9_]+\="[^"]*")/&/ge

  s/><\//><\//e

  if getline('.') !~ '\s*<'
    s/\/\?>\s*$/&/e
  endif

  exec "normal =".startline."gg"

  let &gdefault = def
endfunc
"alignment and closing errors{{{1
map <buffer> <leader>;a :call <sid>findAlignmentErrors()<cr>
func! <sid>findAlignmentErrors()
  let startingPoint = getcurpos()
  normal ggVG=
  let line = 0
  let stack = []
  while line <= line('$')
    let text = getline(line)
    if match(text, '^\s*<\!') != -1
      "do nothing with comments
    elseif text =~ '^\s*<\/'
      let items = matchlist(text, '\v^(\s*)\<\/([^\ >]*)')
      if len(items) >= 3 && len(stack)
        let endIndent = len(items[1])
        let endTag = items[2]
        let [startLine, startIndent, startTag] = stack[-1]
        if endIndent != startIndent || startTag != endTag
          call cursor(startLine, startIndent)
          normal zz
          return
        endif
        let stack = stack[:-2]
      endif
    elseif text =~ '^\s*\/>'
      let stack = stack[:-2]
    elseif text =~ '^\s*<'
      let items = matchlist(text, '^\(\s*\)<\([^\ >]*\)')
      if len(items) >= 3
        let indent = len(items[1])
        let tag = items[2]
        "check to make sure it's not closed on this line!
        let isClosed = text =~ ('<\/'.tag) || text =~ '\/>\s*$'
        if !isClosed
           call add(stack, [line, indent, tag])
        endif
      endif
    endif
    let line += 1
  endwhile

  if len(stack)
    let [startLine, startIndex, startTag] = stack[0]
    call cursor(startLine, startIndex)
  else
    call setpos('.', startingPoint)
    normal zz
  endif
endfunc
