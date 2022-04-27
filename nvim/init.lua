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

-- setup {{{1
vim.g.mapleader = ' ' --space

-- plugins {{{1
  -- set up the package manager {{{2
  local packer_dir = vim.fn.expand "~/config/nvim/pack/plugins/opt/packer.nvim"
  local packer_repo = "https://github.com/wbthomason/packer.nvim"
  local is_setup = false
  if 0 == vim.fn.isdirectory(packer_dir) then
    is_setup = true
    vim.cmd("!mkdir -p " .. packer_dir)
    vim.cmd("!git clone --depth 1 " .. packer_repo .. " " .. packer_dir)
  end
  vim.cmd [[set packpath += "~/config/nvim/plugins"]]
  vim.cmd [[packadd packer.nvim]]

  -- set up the plugins {{{2
  require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- colorsceme plugins {{{3
    use 'xolox/vim-misc'
    use 'xolox/vim-colorscheme-switcher'
    use 'flazz/vim-colorschemes'
    use 'trevordmiller/nova-vim'
    use 'AlessandroYorba/Arcadia'
    use 'jnurmine/Zenburn'

    -- use 'freitass/todo.txt-vim'
    -- use 'junegunn/limelight.vim'
    -- use 'junegunn/goyo.vim'
    -- use 'Raimondi/delimitMate'
    -- use 'PeterRincker/vim-argumentative'
    -- use 'reedes/vim-pencil'
    -- use 'tpope/vim-obsession'
    use 'tpope/vim-surround'
    use 'tpope/vim-commentary'
    -- use 'will133/vim-dirdiff'
  end)

  -- do the install if this is a setup run
  if is_setup then
    vim.cmd [[PackerSync]]
  end


-- fast config {{{1
vim.cmd [[
  nnoremap <leader>c :call J_reloadConfig()<CR><CR>
  nnoremap <leader>C :call J_goConfig()<CR><CR>

  func! J_goConfig()
    let parts = split(&filetype, '\.')
    let ft = len(parts) > 0 ? parts[0] : ""

    let files = "~/config/dotfiles/vimrc.vim"

    if !empty(ft)
      let files = files . " ~/.vim/ftplugin/".ft.".vim"
    endif

    if has('nvim')
      let files = "~/.config/nvim/init.lua " . files
    endif

    exec '!tmux new-window "nvim -c \"let g:configMode=1\" -O ' . files . '"'
  endfunc
  augroup ConfigReload
      au!
      autocmd bufwritepost *.vim call J_reloadConfig()
  augroup end

  if !exists('*J_reloadConfig')
    func J_reloadConfig()
      silent source ~/config/nvim/init.lua
      filetype detect
    endfunc
  endif
]]
-- color settings {{{1
vim.cmd [[colorscheme neodark | set bg=dark]]

-- window/tab manipulation {{{1
vim.opt.equalalways = true --automatically resize windows

vim.api.nvim_set_keymap('n', '<leader>=', ':Vexplore!<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>-', ':Sexplore<cr>', {})

vim.api.nvim_set_keymap('n', '<leader>k', '<c-w>k', {})
vim.api.nvim_set_keymap('n', '<leader>j', '<c-w>j', {})
vim.api.nvim_set_keymap('n', '<leader>l', '<c-w>l', {})
vim.api.nvim_set_keymap('n', '<leader>h', '<c-w>h', {})

vim.api.nvim_set_keymap('n', '<leader>K', '<C-W>K', {})
vim.api.nvim_set_keymap('n', '<leader>J', '<C-W>J', {})
vim.api.nvim_set_keymap('n', '<leader>L', '<C-W>L', {})
vim.api.nvim_set_keymap('n', '<leader>H', '<C-W>H', {})

vim.api.nvim_set_keymap('n', '<leader>w', '<C-W>', {})

vim.api.nvim_set_keymap('n', '<leader>tj', ':call MoveWindowTo#NextTab()<CR>', {})
vim.api.nvim_set_keymap('n', '<leader>tk', ':call MoveWindowTo#PrevTab()<CR>', {})
vim.api.nvim_set_keymap('n', '<leader>tn', ':0tabnew<CR>', {})
vim.api.nvim_set_keymap('n', '<leader>tc', ':tabclose<CR>', {})
vim.api.nvim_set_keymap('n', '<leader>to', ':tabonly<CR>', {})

vim.api.nvim_set_keymap('n', '<leader><Down>', '<C-W>+', {})
vim.api.nvim_set_keymap('n', '<leader><Up>', '<C-W>-', {})
vim.api.nvim_set_keymap('n', '<leader><Left>', '<C-W><', {})
vim.api.nvim_set_keymap('n', '<leader><Right>', '<C-W>>', {})
vim.api.nvim_set_keymap('n', '<Down>',  '<C-W>+', {})
vim.api.nvim_set_keymap('n', '<Up>',    '<C-W>-', {})
vim.api.nvim_set_keymap('n', '<Left>',  '<C-W><', {})
vim.api.nvim_set_keymap('n', '<Right>', '<C-W>>', {})
