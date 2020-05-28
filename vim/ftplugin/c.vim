" OmniCppComplete initialization
"call omni#cpp#complete#Init()

setlocal indentexpr=CppIndentCalc(v:lnum)
setlocal indentkeys=o,O,*<Return>,<CR>,{,},:

inoremap <buffer> <expr> . SmartDot()
func! SmartDot()
  let line = getline('.')
  if line[len(line)-1] == '.'
    return "s->"
  endif
  return '.'
endfunc

nnoremap  <buffer> <leader>;h :w<CR>:e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<CR>
