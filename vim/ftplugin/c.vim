" OmniCppComplete initialization
"call omni#cpp#complete#Init()

setlocal indentexpr=CppIndentCalc(v:lnum)
setlocal indentkeys=o,O,*<Return>,<CR>,{,},:

nnoremap  <buffer> <leader>;h :w<CR>:e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<CR>
