
setlocal errorformat=%f:0(%l)\ :\ error\ C%n:\ %m

nnoremap  <buffer> <F3> :vsplit<CR>:e %:p:s,.vs$,.X123X,:s,.fs$,.vs,:s,.X123X$,.fs,<CR>
inoremap  <buffer> <F3> <ESC><F3>
set iskeyword=@,48-57,_,192-255
