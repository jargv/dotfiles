" OmniCppComplete initialization
"call omni#cpp#complete#Init()

" swap header and source
setlocal indentexpr=CppIndentCalc(v:lnum)
setlocal indentkeys=o,O,*<Return>,<CR>,{,},:
