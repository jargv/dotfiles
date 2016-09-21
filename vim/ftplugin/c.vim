" OmniCppComplete initialization
"call omni#cpp#complete#Init()

" swap header and source
nnoremap  <buffer> <F3> :vsplit<cr>:w<CR>:e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<CR>
inoremap  <buffer> <F3> <ESC><F3>
setlocal indentexpr=CppIndentCalc(v:lnum)
setlocal indentkeys=o,O,*<Return>,<CR>,{,},:
