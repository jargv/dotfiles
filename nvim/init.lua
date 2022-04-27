-- Legacy Mode for using old vim config {{{1
local legacy_config_mode = true
if legacy_config_mode then
  vim.cmd [[
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath = &runtimepath
    source ~/.vimrc
  ]]
  return
end
