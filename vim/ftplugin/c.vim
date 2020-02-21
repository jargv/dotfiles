" OmniCppComplete initialization
"call omni#cpp#complete#Init()

setlocal indentexpr=CppIndentCalc(v:lnum)
setlocal indentkeys=o,O,*<Return>,<CR>,{,},:
