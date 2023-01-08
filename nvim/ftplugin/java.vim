"Settings {{{1
setlocal indentkeys=o,O,*<Return>,<CR>,{,}
setlocal shiftwidth=4 tabstop=4
setlocal omnifunc=javacomplete#Complete
set nocindent nosmartindent autoindent

lua <<
local config = {
  cmd = {'/bin/jdtls'},
  root_dir = vim.fs.dirname(vim.fs.find({'.gradlew', '.git', 'mvnw'}, { upward = true })[1]),
}
require('jdtls').start_or_attach(config)
.

nnoremap <A-i> <Cmd>lua require'jdtls'.organize_imports()<CR>
