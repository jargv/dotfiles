"setup {{{1
let mapleader = " "
set shortmess+=I
let g:isLinux = system('uname') == "Linux\n"
let g:isMac = !g:isLinux

"plugins {{{1
"setup Plug {{{2
"install setup {{{3
    let plugDir = "~/config/nvim/plug"
    let plugDoInstall = 0
    if !isdirectory(expand(plugDir))
      let plugUrl = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
      let plugFile = plugDir . "/plug/autoload/plug.vim"
      exec "!curl -fLo ".plugFile." --create-dirs " . plugUrl
      let plugDoInstall = 1
    endif
"normal setup {{{3
    filetype off
    "set runtimepath=$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,~/.vim/plug/plug
    set runtimepath+=~/config/nvim/plug/plug
    call plug#begin('~/config/nvim/plug')
"}}}
"}}}
lua plugin_setup_funcs = {}

  "Language-specifig plugins {{{2
   "powershell {{{3
   "Plug 'PProvost/vim-ps1'

   "rust {{{3
   " Plug 'rust-lang/rust.vim'
   " Plug 'racer-rust/vim-racer'
   let g:racer_experimental_completer = 1
   "let g:ycm_rust_src_path = '~/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src'

   "go {{{3
   "Plug 'jargv/vim-go-error-folds'
   " Plug 'fatih/vim-go'
   let g:go_fmt_command = "goimports"
   let g:go_fmt_command = "gofmt"
   let g:go_fmt_fail_silently = 1
   let g:go_def_mapping_enabled = 0

   "don't do whitespace errors, go fmt will eliminate them
   let g:go_highlight_trailing_whitespace_error = 0
   let g:go_highlight_array_whitespace_error = 0
   let g:go_highlight_chan_whitespace_error = 0
   let g:go_highlight_space_tab_error = 0

   "highlight a bunch of stuff
   let g:go_highlight_operators = 1
   let g:go_highlight_functions = 1
   let g:go_highlight_methods = 1
   let g:go_highlight_structs = 1
   let g:go_highlight_interfaces = 1
   let g:go_highlight_build_constraints = 1
   let g:go_auto_type_info = 0

   "I like my own K key, thanks
   let g:go_doc_keywordprg_enabled = 0

   "I only want my own snippets
   let g:go_snippet_engine = ""

   "I don't want the templates
   let g:go_template_autocreate = 0

   " "Scope guru to the whole gopath
   " let g:go_guru_scope = [""]
   "javascript/typescript {{{3
   "Plug 'ternjs/tern_for_vim'
   "Plug 'jxnblk/vim-mdx-js'
   Plug 'pangloss/vim-javascript'
   "Plug 'mxw/vim-jsx'
   "Plug 'jelera/vim-javascript-syntax'
   let g:jsx_ext_required = 0
   Plug 'leafgarland/typescript-vim'
   "Plug 'peitalin/vim-jsx-typescript'
   "Plug 'MaxMellon/vim-jsx-pretty'
   "html {{{3
   Plug 'othree/html5.vim'

   "purescript {{{3
   "Plug 'raichoo/purescript-vim'

   "css {{{3
   Plug 'JulesWang/css.vim'

   "html {{{3
   "Plug 'mattn/emmet-vim'
   "toml {{{3
   Plug 'cespare/vim-toml'
   "docker {{{3
   "Plug 'ekalinin/Dockerfile.vim'

   "glsl {{{3
   Plug 'vim-scripts/glsl.vim'

   "lua {{{3
    "Plug 'SpaceVim/vim-swig'

   "markdown {{{3
   Plug 'JamshedVesuna/vim-markdown-preview'
   let vim_markdown_preview_github=1
   "}}}
   "zig {{{3
   Plug 'ziglang/zig.vim'
   let g:zig_fmt_autosave = 0

   "colorschemes {{{2
   "Plug 'xolox/vim-misc'
   "Plug 'xolox/vim-colorscheme-switcher'
   "Plug 'flazz/vim-colorschemes'
   Plug 'arcticicestudio/nord-vim'
   "Plug 'trevordmiller/nova-vim'
   "Plug 'AlessandroYorba/Arcadia'
   "Plug 'jnurmine/Zenburn'
   "}}}

Plug 'nvim-lua/plenary.nvim'

Plug 'freitass/todo.txt-vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'
Plug 'Raimondi/delimitMate'
Plug 'PeterRincker/vim-argumentative'
Plug 'reedes/vim-pencil'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'will133/vim-dirdiff'

Plug 'neovim/nvim-lspconfig'
Plug 'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  "Plug 'SmiteshP/nvim-navic'
  Plug 'SmiteshP/nvim-navic'
  let g:winbarShown = 0
  func! <sid>toggleWinbar()
    let g:winbarShown = !g:winbarShown
    if g:winbarShown
      set winbar=%{%v:lua.require'nvim-navic'.get_location()%}
    else
      set winbar=
    endif
  endfunc
  nmap <leader>v :call <sid>toggleWinbar()<cr>
"Plug 'mazubieta/gitlink-vim' {{{2
Plug 'mazubieta/gitlink-vim'
function! CopyGitLink(...) range
  redir @+
  echo gitlink#GitLink(get(a:, 1, 0))
  redir END
endfunction
nmap <leader>gl :call CopyGitLink()<CR>
vmap <leader>gl :call CopyGitLink(1)<CR>

  "Plug 'dense-analysis/ale' {{{2
  let g:ale_fixers = {
        \   'javascript': ['prettier'],
        \   'typescript': ['prettier'],
        \   'javascriptreact': ['prettier'],
        \   'css': ['prettier'],
        \   'go': ['goimports'],
        \}
        "\   'c': ['clang-format', 'clangtidy'],
  let g:ale_linters_explicit = 1
  let g:ale_fix_on_save = 1
  let g:ale_completion_autoimport = 1
  Plug 'dense-analysis/ale'

  "Plug 'Valloric/YouCompleteMe' {{{2
  command! YouCompleteMeInstall
        \ :!cd ~/.vim/plug/YouCompleteMe
        \ && git submodule update --init --recursive
        \ && ./install.py
        \ --clang-completer
        \ --ts-completer
        \ --go-completer

  "Plug 'Valloric/YouCompleteMe'
  ""let g:ycm_min_num_identifier_candidate_chars = 99 "only complete on '.' or '->'
  "let g:ycm_min_num_identifier_candidate_chars = 0
  "let g:ycm_filetype_whitelist = {'cpp':1, 'hpp':1, 'typescript':1, 'typescript.tsx':1, 'c':1, 'h':1, 'go':1}
  "let g:ycm_show_diagnostics_ui = 0
  "let g:ycm_enable_diagnostic_signs = 0
  "let g:ycm_autoclose_preview_window_after_completion = 0
  "let g:ycm_autoclose_preview_window_after_insertion = 0
  "let g:ycm_use_ultisnips_completer = 1
  "let g:ycm_key_list_select_completion = ['<C-N>']
  "let g:ycm_key_list_previous_completion = ['<C-P>']
  "let g:ycm_echo_current_diagnostic = 0
  "let g:ycm_clangd_args = ['-cross-file-rename']
  "let g:ycm_clangd_binary_path = exepath("clangd")
  "let g:ycm_clangd_uses_ycmd_caching = 0

  "let g:ycm_add_preview_to_completeopt = 0
  "let g:ycm_min_num_of_chars_for_completion = 1
  "let g:ycm_auto_trigger = 1
  "let g:ycm_disable_signature_help = 0
  "let g:ycm_auto_hover = ''

  "augroup YCMCCustom
  "  autocmd!
  "  autocmd FileType c,cpp let b:ycm_hover = {
  "        \ 'command': 'GetDoc',
  "        \ 'syntax': &filetype
  "        \ }
  "augroup END

  "nmap <leader>;t <plug>(YCMHover)
  "nnoremap <leader>;T :YcmCompleter GetType<cr>
  "nnoremap <leader>;d :YcmCompleter GetDoc<cr>
  "nnoremap <leader>;u :YcmCompleter GoToReferences<cr>
  "nnoremap <leader>;f :YcmCompleter FixIt<cr>
  "nnoremap <leader>;n :exec "YcmCompleter RefactorRename ".input(">", expand("<cword>"))<cr>
  "nnoremap gd :YcmCompleter GoTo<cr>
  "nnoremap <leader>;i :YcmCompleter OrganizeImports <cr>

" configured plugins
  "Plug 'dhruvasagar/vim-table-mode' {{{2
    let g:table_mode_map_prefix = "<Leader>tt"
    Plug 'dhruvasagar/vim-table-mode'

   "Plug 'terryma/vim-expand-region' {{{2
   Plug 'terryma/vim-expand-region'
   xmap v <Plug>(expand_region_expand)

   "Plug 'junegunn/fzf' {{{2
   let g:fzf_buffers_jump = 1
   Plug 'junegunn/fzf'
   Plug 'junegunn/fzf.vim'
   nnoremap <leader>o :FZF --inline-info <cr>
   nnoremap <leader>i :Buffers<cr>

   "Plug 'junegunn/vim-easy-align' {{{2
     Plug 'junegunn/vim-easy-align'
     vmap ga <Plug>(EasyAlign)
   "Plug 'majutsushi/tagbar' {{{2
      "Plug 'majutsushi/tagbar'
      let g:tagbar_left = 1
      nnoremap <leader>, :TagbarOpenAutoClose<cr>
      "let g:tagbar_vertical = 30

   "Plug 'tpope/vim-vinegar' {{{2
     nmap - k
     Plug 'tpope/vim-vinegar'
     nnoremap <leader>d :Explore<cr>
     " nnoremap <leader>D :exec ":e ".getcwd()<cr>

   "Plug 'tpope/vim-fugitive' {{{2
      "Plug 'tpope/vim-fugitive'
      " augroup Fugitive
      "    autocmd!
      "    autocmd BufReadPost fugitive://* set bufhidden=delete
      " augroup END

   "Plug  'SirVer/UltiSnips' {{{2
      Plug 'SirVer/UltiSnips'
      let g:UltiSnipsExpandTrigger="<tab>"
      let g:UltiSnipsJumpForwardTrigger="<tab>"
      let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

      let g:UltiSnipsEditSplit = 'vertical'
      let g:UltiSnipsSnippetsDir = '~/config/nvim/my_snippets'

      let g:UltiSnipsSnippetDirectories=["my_snippets"]

      map <leader>s :UltiSnipsEdit<CR>

  "Plug 'phaazon/hop.nvim' {{{2
    Plug 'phaazon/hop.nvim'
    map <leader>f :HopChar1<cr>
    map <leader>F :HopChar1MW<cr>
lua <<EOF

  table.insert(plugin_setup_funcs, function()
    require('hop').setup()
  end)
EOF

   "Plug 'Lokaltog/vim-easymotion' (unused) {{{2
   " Plug 'easymotion/vim-easymotion'
   "    let g:EasyMotion_do_mapping = 0

   "    map <leader>f <Plug>(easymotion-s)

   "    let g:EasyMotion_keys = 'abcdefghijklmnopqrstuvwxyz'
   "    let g:EasyMotion_do_shade = 0

"Plug 'lewis6991/gitsigns.nvim' {{{2
Plug 'lewis6991/gitsigns.nvim'
func! GitAdjacentChange(next)
  if &diff
    if a:next
      normal ]c
      normal zz
    else
      normal [c
      normal zz
    endif
  else
    if a:next
      lua package.loaded.gitsigns.next_hunk()
      normal zz
    else
      lua package.loaded.gitsigns.prev_hunk()
      normal zz
    endif
  endif
endfunc
nnoremap gn :call GitAdjacentChange(1)<cr>
nnoremap gp :call GitAdjacentChange(0)<cr>
nnoremap gr :Gitsigns reset_hunk<cr>
nnoremap gs :Gitsigns stage_hunk<cr>
nnoremap gS :Gitsigns undo_stage_hunk<cr>
onoremap ih :<C-U>Gitsigns select_hunk<cr>
xnoremap ih :<C-U>Gitsigns select_hunk<cr>
lua <<EOF
  table.insert(plugin_setup_funcs, function()
    require('gitsigns').setup()
  end)
EOF
   "}}}

"Run plugin setup {{{2
call plug#end()
"my shiz should override EVERYTHING
set runtimepath-=~/config/nvim "remove first so that the add occurs at the end
set runtimepath+=~/config/nvim

filetype plugin indent on
if plugDoInstall
    PlugInstall!
    let plugDoInstall = 0
endif
lua <<
  for _,fn in ipairs(plugin_setup_funcs) do
    fn()
  end
.
"}}}

" lsp config {{{1
"
command LspKillAll :lua vim.lsp.stop_client(vim.lsp.get_active_clients())<cr>

if !exists('g:lsp_configured')
lua <<

  local lspconfig = require "lspconfig"
  local util = require "lspconfig/util"
  local navic = require "nvim-navic"

  local capabilities = require'cmp_nvim_lsp'.update_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  )

  lspconfig.clangd.setup{
    capabilities = capabilities,
    on_attach = function(client, buffnr)
      navic.attach(client, buffnr)
    end
  }
  lspconfig.tsserver.setup{capabilities = capabilities}

  lspconfig.gopls.setup{
    capabilities = capabilities,
    cmd = {"gopls", "serve"},
    filetypes = {"go", "gomod"},
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
  }

  vim.diagnostic.config({signs = false, virtual_text = false, underline = false})
  require'toggle_lsp_diagnostics'.init({signs = false, virtual_text = true, underline = true})
.
let g:lsp_configured = 1
endif

nnoremap <silent> <leader>Y
      \ <cmd>wall<cr>
      \ <cmd>ToggleDiagOff<cr>
      \ <cmd>cclose<cr>

nnoremap <silent> <leader>y <cmd>call FollowLspErrors()<cr>
func FollowLspErrors()
  ToggleDiagDefault
  cclose
  lua vim.diagnostic.setqflist({open = false})
  cwindow
  if &ft == "qf"
    normal 
  endif
endfunction

nnoremap <leader>rn :lua vim.lsp.buf.rename(vim.fn.input('>'))<cr>
nnoremap <leader>rf :lua vim.lsp.buf.code_action()<cr>

nmap gd <cmd>lua vim.lsp.buf.definition()<cr>z<cr>
nmap gD <cmd>lua vim.lsp.buf.declaration()<cr>
nmap gi <cmd>lua vim.lsp.buf.implementation()<cr>
nmap gu <cmd>lua vim.lsp.buf.references()<cr>
nmap gh <cmd>lua vim.lsp.buf.hover()<cr>

"Setup nvim-cmp {{{1
lua <<
local cmp = require 'cmp'
-- local cmp_ultisnips_mappings = require 'cmp_nvim_ultisnips.mappings'

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = function(fallback)
      if
        vim.fn["UltiSnips#CanExpandSnippet"]() == 1 or
        vim.fn["UltiSnips#CanJumpForwards"]() == 1
      then
        fallback()
      elseif cmp.visible() then
        cmp.select_next_item()
      else
        cmp.complete()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'ultisnips' },
    -- { name = 'buffer' },
  })
})
.
"treesitter {{{1
lua <<
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "go", "typescript" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing (for "all")
  ignore_install = {},

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = {},

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
.
  "color settings {{{1
  set termguicolors
  set t_ut= "fix the weird background erasing crap
  set ttyfast
  "colorscheme nord | set bg=light
  "colorscheme nova | set bg=light
  "colorscheme oceanlight
  "colorscheme OceanicNext | set bg=dark
  "colorscheme rakr-light | set bg=light
  colorscheme neodark | set bg=dark
  "highlight MatchParen cterm=inverse ctermbg=black
  ":NoMatchParen
  let g:loaded_matchparen = 1

  "if &diff
  "  "colorscheme neodark | set bg=dark
  "  "colorscheme zenburn | set bg=dark
  "  "colorscheme OceanicNext | set bg=dark
  "  colorscheme ironman | set bg=light
  "  "colorscheme rakr-light | set bg=light
  "endif

  nnoremap <f3> :NextColorScheme<cr>
  nnoremap <f2> :PrevColorScheme<cr>
  nnoremap <f1> :RandomColorScheme<cr>
  if mapcheck("<F8>", "n")
    nunmap <F8>
  endif
  "highlight Comment cterm=italic


"signcolumn settings {{{1
highlight! clear SignColumn
highlight link SignColumn LineNr
"highlight SignColumn ctermbg=blue ctermfg=white
set signcolumn=number

"prototype settings {{{1
nnoremap <c-k> [{
nnoremap <c-j> ]}

nnoremap <leader>tN :tab split<cr>
set updatetime=300
"settings {{{1
  "vim, not vi! {{{2
  set nocompatible
  filetype plugin indent on
  syntax on
  syntax enable
  "formatting {{{2
  set formatoptions+=j "fix up comments when they are joined
  "indentation {{{2
  set nocindent nosmartindent autoindent
  set nolist
  set listchars=tab:\|\ ,

  "temporary files (in /tmp, not used) {{{2
  set backupdir=/tmp directory=/tmp undodir=/tmp
  set nobackup noswapfile
  "Timeout stuff (keep vim snappy) {{{2
  set notimeout
  set ttimeout
  set ttimeoutlen=0
  "search {{{2
  set wildmode=full
  set gdefault "always use the g flag in %s///g
  set ignorecase smartcase incsearch hlsearch wrapscan
  nnoremap <C-L> :nohlsearch<cr>:syn sync minlines=99999<cr><C-L>
  "}}}
  "folds {{{2
  "blow away the wonky dashes in the folds {{{3
  set fillchars="fold: "
  "close a fold by moving left into the number column {{{3
  nnoremap <expr> h MoveLeft()
  func! MoveLeft()
    if getpos('.')[2] == 1
      return "zc"
    else
      return "h"
    endif
  endfunc
  "set the fold text {{{3
  set foldtext=MyFoldText()
  function! MyFoldText()
    let sub = substitute(foldtext(), '+-*\s*\d*\s*lines:\s*', '', 'g')
    return repeat(' ', &sw * (v:foldlevel - 1)) . sub
  endfunction
  "}}}

  "spell check {{{2
  set spelllang=en_us nospell
  "buffers{{{2
  set autoread
  set splitbelow splitright
  "my autochdir (not in use) {{{3
  "  func! AutoChdir()
  "     if !exists('b:onAutoChDir')
  "        silent! exec ":cd ".expand("%:p:h")
  "     else
  "        exec b:onAutoChDir
  "     endif
  "  endfunc

  "  augroup AutoChdir
  "     autocmd!
  "     autocmd BufEnter * call AutoChdir()
  "  augroup END
  "No simultaneous edits {{{3
  augroup NoSimultaneousEdits
    autocmd!
    autocmd  SwapExists * :let v:swapchoice = 'e'
  augroup END
  "}}}
  "difftool {{{2
  set diffopt=
  set diffopt+=filler "show filler lines to keep everything in sync
  set diffopt+=iwhite "ignore whitespace
  "whitespace {{{2
  "tab characters {{{3
  set tabstop=2 shiftwidth=2 expandtab smarttab shiftround
  ""highlight trailing whitespace {{{3
  "highlight TrailingWhitespace cterm=underline
  "match TrailingWhitespace /\s\+\%#\@<!$/
  "match TrailingWhitespace /\s\+$/
  ""blow away trailing whitespace {{{3
  autocmd BufWritePre * :call RemoveTrailingWhitespace()
  command! Fws :call RemoveTrailingWhitespace()
  func! RemoveTrailingWhitespace()
    let save_cursor = getpos(".")
    %s/\s\+$//e
    call setpos('.', save_cursor)
    nohlsearch
  endfunc
  "}}}
  " indentation/wrapping {{{2
  set nojoinspaces
  set wrap
  set linebreak
  set breakindent
  set breakindentopt=shift:0,sbr
  let &showbreak='> '
  let &breakat=" 	!@*-+;:,./?(){}[]"
  "set cpoptions+=n
  "other {{{2
  let g:filetype_pl="prolog"
  set scrolloff=5
  set nofileignorecase
  set virtualedit=block "allow moving onto whitespace during block select
  set noreadonly "I never really care about using readonly
  set wildmenu wildmode=full
  set autowrite autowriteall
  set backspace=indent,eol,start
  set switchbuf=useopen,usetab
  set undofile hidden history=1000 " keep undo history in buffers when not visible/open
  set completeopt=menuone,noinsert
  set infercase
  set mouse=a
  if has("mouse_sgr")
    set ttymouse=sgr
  endif
  if g:isLinux
    set clipboard=unnamedplus
  else
    set clipboard=unnamed
  endif
  "}}}

"fast config {{{1
  nnoremap <leader>c :call <SID>reloadConfig()<CR><CR>
  nnoremap <leader>C :call <SID>goConfig()<CR><CR>

  func! <SID>goConfig()
    let parts = split(&filetype, '\.')
    let ft = len(parts) > 0 ? parts[0] : ""

    let files = "~/config/nvim/init.vim"

    if !empty(ft)
      let files = files . " ~/config/nvim/ftplugin/".ft.".vim"
    endif

    exec '!tmux new-window "nvim -c \"let g:configMode=1\" -O ' . files . '"'
  endfunc
  augroup ConfigReload
      au!
      autocmd bufwritepost *.vim call <SID>reloadConfig()
  augroup end

  if !exists('*<SID>reloadConfig')
    func <SID>reloadConfig()
      lua require('reset_modules')()
      silent source ~/config/nvim/init.vim
      filetype detect
    endfunc
  endif
"compiler <leader>m {{{1
  func! <SID>InitMyMake()
    let g:makeBuildtool = ""
    let g:makeTarget = ""
    let g:runTarget = ""
    let g:makeDirectory = ""

    let g:makeOnSave = 0
    let g:closeOnCollectErrors = 0

    let g:browserReloadOnMake = 0
    let g:browserReloadCommand = 'chrome_refresh'
    let g:browserReloadArgs = ""
    let g:browserReloadPort = ""

    let g:tmux_pane_id=""
  endfunc

  func! <sid>MakeOnSave()
    if g:makeOnSave
      call <sid>RunMake()
    endif
  endfunc

  "autocommand on save
  augroup MakeOnSaveGroup
     autocmd!
     autocmd BufWritePost * call <sid>MakeOnSave()
  augroup END

  "ensure the variables always exist
  if !exists("g:makeTarget") || !exists("g:makeBuildtool")
    call <SID>InitMyMake()
  endif

  nnoremap <leader>m <cmd>cclose<cr> <cmd>wall<cr> <cmd>call <SID>RunMake()<cr>
  nnoremap <leader>MM :call <SID>DetectBuildTool()<cr>
  nnoremap <leader>e :call <SID>CollectErrors()<cr>
  nnoremap <leader>Ms :call <SID>ToggleMakeOnSave()<cr>

  nnoremap <leader>Mq :call <sid>clearMakeFunction()<cr>:call <sid>InitMyMake()<cr>
  nnoremap <leader>Mb :call <SID>ToggleReloadBrowserOnMake()<cr>

  nnoremap <leader>Mt :call <sid>setMakeTarget()<cr>
  func! <sid>setMakeTarget()
    let g:makeTarget = input(">", g:makeTarget)
    call <sid>generateMakeFunction()
  endfunc

  nnoremap <leader>Mr :call <sid>setRunTarget()<cr>
  func! <sid>setRunTarget()
    let g:runTarget = input(">", g:runTarget)
    call <sid>generateMakeFunction()
  endfunc

  nnoremap <leader>Mx :call <sid>setBuildTool()<cr>
  func! <sid>setBuildTool()
    let g:makeBuildtool = input(">", g:makeBuildtool)
    call <sid>generateMakeFunction()
  endfunc

  nnoremap <leader>Md :call <sid>setMakeDirectory()<cr>
  func! <sid>setMakeDirectory()
    let g:makeDirectory = input(">", len(g:makeDirectory) ? (g:makeDirectory) : getcwd())
    call <sid>generateMakeFunction()
  endfunc

  nnoremap <leader>Mp :echo "nope not implemented"<cr>
    ":let g:browserReloadPort = input('Port:', g:browserReloadPort ? g:browserReloadPort : '')<cr>

  func! <SID>CollectErrors()
    let cwd = getcwd()
    "exec "cd ".g:makeDirectory
    cfile! /tmp/vim-errors
    "call setqflist(filter(getqflist(), "v:val['lnum'] != 0"))
    cw
    normal <cr>
    exec "cd ".cwd
  endfunc

  func! <SID>ToggleReloadBrowserOnMake()
    if !g:browserReloadOnMake
      echom "Reload browser on save [ON]"
    else
      echom "Reload browser on save: [OFF]"
      let g:browserReloadArgs = ""
    endif
    let g:browserReloadOnMake = !g:browserReloadOnMake
    call <sid>generateMakeFunction()
  endfunc

  func! <SID>ToggleMakeOnSave()
     let g:makeOnSave = !g:makeOnSave
     if g:makeOnSave
        echo "Make on Save [ON]"
     else
        echo "Make on Save [OFF]"
     endif
  endfunc

  func! <SID>CollectTmuxPane()
    call system("tmux display-pane 'display -t \%\% \"#P\"'")
    let pane_index = input("pane:")
    let pane = system("tmux display -p -t".pane_index." '#{pane_id}'")
    let pane = substitute(pane, '\n', '', '')
    return pane
  endfunc

  func! <SID>TmuxRun(args)
    if g:tmux_pane_id == ""
      let g:tmux_pane_id = <SID>CollectTmuxPane()
    endif

    call system("tmux send-keys -t ".g:tmux_pane_id.' ^C')
    call system("tmux send-keys -t ".g:tmux_pane_id.' "'.escape(a:args,'\"$`').'"'.' Enter')
  endfunc

  func! <SID>DetectBuildTool()
    call <SID>InitMyMake()
    let g:makeDirectory = getcwd()
    let g:makeOnSave = 1
    if filereadable("build.zig")
      let g:makeBuildtool = "zig"
      let g:makeTarget = "build run"
    elseif filereadable("meson.build")
      if !isdirectory("build")
        call <SID>TmuxRun("meson setup build")
        call system("ln -sf build/compile_commands.json .")
        call input("press enter when the build has generated...")
      endif
      let g:makeDirectory .= "/build"
      let g:makeBuildtool = "ninja"
    elseif filereadable("CMakeLists.txt")
      if !isdirectory("build")
        "call <SID>TmuxRun("mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=DEBUG -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. && cd ..")
        call <SID>TmuxRun("mkdir -p build && cd build && cmake -GNinja -DCMAKE_BUILD_TYPE=DEBUG -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. && cd ..")
        call system("ln -sf build/compile_commands.json .")
        call input("press enter when the build has generated...")
      endif
      let g:makeDirectory .= "/build"
      let g:makeBuildtool = "cmake --build ."
    elseif expand('%:e') == "go"
      let testExt = "_test.go"
      let file = expand('%:p')
      if file[-len(testExt):] == testExt
        let g:makeBuildtool = "go test"
        let g:makeTarget = ""
      elseif filereadable("go.mod")
        let g:makeBuildtool = "go"
        let g:makeTarget = "build"
      else
        let g:makeBuildtool = "go run ".expand("%")
        let g:makeTarget = ""
      endif
    elseif filereadable("package.json")
      let g:makeBuildtool = "yarn run"
      let g:makeTarget = "build"
    elseif expand('%:e') == "js"
      let g:makeBuildtool = "node"
      let g:makeTarget = expand('%')
    elseif filereadable("tsconfig.json")
      let g:makeDirectory = ""
      let g:makeBuildtool = "tsc --build"
      let g:makeTarget = getcwd()."/tsconfig.json"
    elseif filereadable("Cargo.toml")
      let g:makeBuildtool = "cargo"
      let g:makeTarget = 'run'
    elseif expand('%:e') == "rs"
      let g:makeBuildtool = "rustc"
      let g:makeTarget = expand('%')
    elseif filereadable("gradlew")
      let g:makeBuildtool = "./gradlew"
    elseif filereadable("Makefile") || filereadable("makefile")
      let g:makeBuildtool = "make"
    else
       "just try to execute the file
       let g:makeBuildTool = ""
       let g:makeTarget = "./".expand('%:t')
    endif
    call <sid>generateMakeFunction()
  endfunc

  func! <sid>generateMakeFunction()
    let body = "\n\t" . "set -o pipefail"
    let body = body . "\n\t" . "set -e"

    let dir = g:makeDirectory
    if len(dir) == 0
      let dir = getcwd()
    endif
    let body = body . "\n\t" . "cd " . dir

    if len(g:makeBuildtool) || len(g:makeTarget)
      let body = body . "\n\t" . g:makeBuildtool . " " . g:makeTarget . " 2>&1"
      let body = body . " |tee /tmp/vim-errors"
    endif

    if len(g:runTarget)
      let body = body . "\n\t" . g:runTarget
    endif

    if g:browserReloadOnMake
      if executable("xdotool") && empty(g:browserReloadArgs)
        let g:browserReloadArgs = system("xdotool selectwindow")
      endif
      let body = body . "\n\t" . g:browserReloadCommand . " " . g:browserReloadArgs
    endif

    let message = "echo detected " . g:makeBuildtool . " " . g:makeTarget
    call <sid>TmuxRun("vim_rebuild(){" . body . " }\n " . message)
  endfunc

  func! <sid>clearMakeFunction()
    call <sid>TmuxRun("vim_rebuild(){}")
  endfunc

  func! <SID>RunMake()
    "if g:tmux_pane_id != ""
    "  "wa
    "endif

    call <sid>TmuxRun("(vim_rebuild)")

    " if g:browserReloadPort
    "   let triesRemaining = 100
    "   let success = 0
    "   while !success && triesRemaining
    "     call system("curl -f -s localhost:".g:browserReloadPort)
    "     let success = !v:shell_error
    "     let triesRemaining -= 1
    "   endwhile
    "   if !success
    "     echom "ERROR: Could not restart the server :("
    "     return
    "   endif
    " endif
  endfunc

"<leader>b manual browser refresh {{{1
  let g:manualRefreshArgs = ""
  nnoremap <leader>b :call <sid>manualRefresh()<cr>
  nnoremap <leader>B :let g:browserReloadArgs = ""<cr>
  func! <sid>manualRefresh()
    if g:browserReloadArgs == "" && executable("xdotool")
      let g:browserReloadArgs = system("xdotool selectwindow")
    endif

    call system(g:browserReloadCommand  . " " . g:browserReloadArgs)
  endfunc

" terminals {{{1
"hi Terminal guibg=#f3eaea guifg=#40427f
au BufWinEnter * if &buftype == 'terminal' | setlocal nonumber | endif
if has("gui_running")
  nnoremap <leader>. :term ++curwin<cr>
" elseif has("nvim")
"   nnoremap <leader>. :split term://zsh<cr>:startinsert<cr>
else
  nnoremap <leader>. :!tmux split-window -p20 <CR><CR>
endif

"window/tab manipulation {{{1
  set equalalways "automatically resize windows

  nmap <leader>= :Vexplore!<cr>
  nmap <leader>- :Sexplore<cr>

  nmap <leader>k <c-w>k
  nmap <leader>j <c-w>j
  nmap <leader>l <c-w>l
  nmap <leader>h <c-w>h

  nmap <leader>K <C-W>K
  nmap <leader>J <C-W>J
  nmap <leader>L <C-W>L
  nmap <leader>H <C-W>H

  nmap <leader>w <C-W>

  nmap <leader>tj :call MoveWindowTo#NextTab()<CR>
  nmap <leader>tk :call MoveWindowTo#PrevTab()<CR>
  nmap <leader>tn :0tabnew<CR>
  nmap <leader>tc :tabclose<CR>
  nmap <leader>to :tabonly<CR>

  nmap <leader><Down> <C-W>+
  nmap <leader><Up> <C-W>-
  nmap <leader><Left> <C-W><
  nmap <leader><Right> <C-W>>
  nmap <Down>  5<C-W>+
  nmap <Up>    5<C-W>-
  nmap <Left>  5<C-W><
  nmap <Right> 5<C-W>>

  " tmap <M-k> <c-w>k
  " tmap <M-j> <c-w>j
  " tmap <M-l> <c-w>l
  " tmap <M-h> <c-w>h

  nmap <M-k> <c-w>k
  nmap <M-j> <c-w>j
  nmap <M-l> <c-w>l
  nmap <M-h> <c-w>h

  nnoremap <leader>] :call <SID>bufMove(1, 0)<cr>
  nnoremap <leader>[ :call <SID>bufMove(0, 0)<cr>
  nnoremap <leader>\ :call <SID>bufMove(1, 1)<cr>

  " tnoremap <M-o> <C-w>:call <SID>bufMove(1, 0)<cr>
  " tnoremap <M-i> <C-w>:call <SID>bufMove(0, 0)<cr>
  " tnoremap <M-u> <C-w>::call <SID>bufMove(1, 1)<cr>

  " " Zoom
  " nnoremap <silent> <M-;> :call ZoomToggle()<CR>
  " tnoremap <silent> <M-;> <C-w>:call ZoomToggle()<CR>
  " function! ZoomToggle()
  "   if exists('t:zoomed') && t:zoomed
  "     execute t:zoom_winrestcmd
  "     let t:zoomed = 0
  "   else
  "     let t:zoom_winrestcmd = winrestcmd()
  "     resize
  "     vertical resize
  "     let t:zoomed = 1
  "   endif
  " endfunction

  func! BufDescCmp(a, b)
    if a:a.bufnr < a:b.bufnr
      return -1
    elseif a:a.bufnr > a:b.bufnr
      return 1
    else
      return 0
    endif
  endfunc

  func! <SID>bufMove(next, destroy)
    let current = bufnr("%")
    let buflisted = buflisted(current)
    let bufs = getbufinfo({"buflisted": buflisted})

    if len(bufs) < 2
      return
    endif

    call sort(bufs, function("BufDescCmp"))

    if !a:next
      call reverse(bufs)
    endif

    let current_index = -1
    for i in range(len(bufs))
      let buf = bufs[i]
      if buf.bufnr == current
        let current_index = i
        break
      endif
    endfor

    if current_index == -1
      return
    endif

    for i in range(current_index, 2 * len(bufs))
      let buf = bufs[i % len(bufs)]
      if buf.listed && len(buf.windows) == 0
        exec "b".buf.bufnr
        if a:destroy
          exec "silent bd! ".current
        endif
        return
      endif
    endfor
    if a:destroy
      enew
      exec "bd! ".current
    endif
  endfunc

"mappings {{{1
  "better defaults {{{2
    nnoremap p p=`]
    nnoremap <c-p> p
    nnoremap == ==j
    nnoremap 0 ^
    nnoremap Y y$
    xnoremap R r<space>R
    xnoremap & :&<cr>
    nnoremap * :let @/ = '\<'.expand("<cword>").'\>'<CR>:set hlsearch<CR>:echo<CR>
    "todo: make this work
    "xnoremap * :let @/ = '\<'.expand("<cword>").'\>'<CR>:set hlsearch<CR>:echo<CR>

  "control-move text{{{2
    xnoremap <C-j> xp'[V']
    xnoremap <C-k> xkP'[V']
  "git mappings {{{2
    nnoremap <leader>gD :!tmux new-window "git difftool -w"<cr><cr>
    nnoremap <leader>gd :!tmux new-window "git difftool -w %"<CR><CR>
    nnoremap <leader>gM :!tmux new-window "git difftool -w origin/$(git config j.publish)"<cr><cr>
    nnoremap <leader>gm :!tmux new-window "git difftool -w origin/$(git config j.publish) -- %"<CR><CR>
    nnoremap <leader>gc :!tmux new-window "git bedone"<CR><CR>
    nnoremap <leader>gi :!tmux new-window "git rebase -i"<cr><cr>
    nnoremap <leader>gh :!tmux new-window "git hist --all"<CR><CR>
    nnoremap <leader>gH :!tmux new-window "git hist --simplify-by-decoration"<cr><cr>
    nnoremap <leader>gb :Gitsigns toggle_current_line_blame<cr>
    nnoremap <leader>gB :lua package.loaded.gitsigns.blame_line({full=false,ignore_whitespace=true})<cr>
    nnoremap <leader>gs :!tmux new-window "tig status"<CR><CR>
    nnoremap <leader>gg :exec ":!git ".input("git> ")<CR>
  "working directory mappings {{{2
    nnoremap <leader>U :cd %:p:h<CR>:echo<CR>
    nnoremap <leader>u :cd ..<CR>:echo<CR>


  "make use of Q for quick system-clipboard copying{{{2
    nnoremap Q ggVG
    xnoremap Q "+y
  "uppercase words {{{2
    inoremap <c-u> <esc>vbgU`>a
    nnoremap <c-u> gUiw

  "toggle relative linenumbers {{{2
    "set relativenumber
    nnoremap <leader>3 :call ToggleRelative()<CR>
    func! ToggleRelative()
      if &relativenumber
        set number
        set norelativenumber
      elseif &number
          set nonumber
      else
        set relativenumber
      endif
      echo
    endfunc
    set number

  "fast saving/quitting {{{2
    if !exists("g:MySmartQuitDefined")
        func! MySmartQuit()
          let config = exists("g:configMode") && g:configMode
          if &diff || !len(bufname('%')) || config
              xa!
          elseif has("gui_running")
              silent bw!
          else
              wq!
          endif
        endfunc
        echo
    endif
    let g:MySmartQuitDefined = 1
    nnoremap <leader>q :call MySmartQuit()<cr>
    nnoremap <leader>Q :cquit!<cr>
    nnoremap <leader><leader> :wall<cr>

  "next and previous location/error/vimgrep {{{2
    nnoremap <expr> <silent> <leader>n ((len(getqflist()) ? ":cn" : ":lnext")."<CR>")
    nnoremap <expr> <silent> <leader>p ((len(getqflist()) ? ":cp" : ":lprev")."<CR>")
    nnoremap <expr> <silent> <leader>N ((len(getqflist()) ? ":cnf" : ":lnf")."<CR>")
    nnoremap <expr> <silent> <leader>P ((len(getqflist()) ? ":cpf" : ":lpf")."<CR>")
  "K as the opposite of Join {{{2
    xnoremap <silent> K <Nop>
    nnoremap <silent> K :call <SID>Format() <CR>
    func! <SID>Format()
        normal Vgq
    endfunc

  "incr/decr then save{{{2
    noremap  :w<CR>
    noremap  :w<CR>

  "smart enter key "{{{2
    inoremap <expr> <CR> SmartEnter()
    func! SmartEnter()
      let isLua = &ft == 'lua'
      let isCpp = &ft == 'cpp'

      "select from the popup menu if it's visible
      " if pumvisible()
      "   return ''
      " endif

      let line = getline('.')
      let p = getpos('.')[2]
      let lastChar = line[p-2]
      let restOfLine = (line[p-1:])
      let tab = repeat(' ', &sw)

      if (len(restOfLine) >= 1)
        let nextToLastChar  = line[p-1]
        let brackets = lastChar == '{' && nextToLastChar == '}'
        let parens   = lastChar == '(' && nextToLastChar == ')'
        let squares  = lastChar == '[' && nextToLastChar == ']'
        if brackets || parens || squares
          if isCpp && brackets && line =~ '\v^\s*(class)|(struct)'
            return 'A;O'
          endif
          return 'O'
        else
          return ''
        endif
      elseif len(restOfLine) == 0
        if     lastChar == '{' | return '}O'
        elseif lastChar == '(' | return ')O'
        elseif lastChar == '[' | return ']O'
        elseif isLua && pumvisible() && (line[-4:] == 'then' || line[-2:] == 'do') | return 'endO'
        elseif isLua && (line[-4:] == 'then' || line[-2:] == 'do') | return 'endO'
        else                   | return ''
        endif
      endif
      return "" "'O'
    endfunc
  " get the styles under the cursor {{{2
    map <leader>S :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
  "}}}


"cursor {{{1
   "use the cursorline as mode indicator {{{2
      " autocmd InsertEnter * set cursorline
      " autocmd InsertLeave * set nocursorline
      " highlight CursorLine cterm=none
      " set nocursorline
      "
   "}}}

   "tabline {{{1
      nnoremap <leader>gt :let g:gitStatusInTablineShown = !g:gitStatusInTablineShown<cr><C-L>
      if !exists('g:gitStatusInTablineShown')
         let g:gitStatusInTablineShown = 0
      endif
      if has("gui_running")
        set showtabline=1
      else
        set showtabline=2
      endif
      func! GetGitBranch()
         if g:gitStatusInTablineShown
           let cmd = "git status -sb"
         else
           let cmd = "git rev-parse --abbrev-ref HEAD"
         endif
         let branch = substitute(system(cmd), "\n", "", "g")
         return (0 != v:shell_error) ? "[vim]" : ''.branch.''
      endfunc
      func! MyTabLabel(n)
        let buflist = tabpagebuflist(a:n)
        let winnr = tabpagewinnr(a:n)
        let current = fnamemodify(bufname(buflist[winnr - 1]),':t')
        if current == ""
           let current = '[new file]'
        endif
        return current
      endfunction
      func! MyTabLine()
        "let sep = "┋"
        "let sep = "┊"
        "let sep = "█"
        "let sep = "▓"
        "let sep = "░"
        let sep = " "
        let s = " nvim "
        "let s = "     "
        let selected = tabpagenr()
        let num = tabpagenr('$')
        for i in range(num)
          let isSelected = i + 1 == selected
          let isFirst = selected == 1 && i == 0
          let after = i == selected

          if isSelected
            let s .= '%#TabLineSel#'
          elseif i == tabpagenr()
            let s .= '%#TabLine#'
          else
            let s .= '%#TabLine#'
            let s .= sep
          endif

          " set the tab page number (for mouse clicks)
          let s .= '%' . (i + 1) . 'T'

          let padding = ''
          if isSelected
            "let padding = sep
            let padding = " "
          endif

          let s .= padding . ' %{MyTabLabel(' . (i + 1) . ')} ' . padding

          if i == num - 1 && selected != num
            let s .= sep
          endif

        endfor
        let s .= '%#TabLineFill# '

        "start on the right
        let s .= '%='
        "let s .= '%#TabLineFill# '.'%{GetGitBranch()}'.' '

        return s
      endfunc
      set tabline=%!MyTabLine()
      "hi TabLineSel          cterm=bold      ctermbg=bg      ctermfg=bg
      " exec "hi TabLineSel          cterm=bold      ctermbg=".s:selBG."      ctermfg=".s:selText
      " exec "hi TabLine             cterm=none      ctermbg=".s:background." ctermfg=".s:text
      " exec "hi TabLineSelSep       cterm=none      ctermbg=".s:background." ctermfg=".s:selBG
      " exec "hi TabLineSelSepBefore cterm=inverse   ctermbg=".s:background." ctermfg=".s:selBG
      " exec "hi TabLineSep          cterm=none      ctermbg=".s:background." ctermfg=".s:selBG
      " exec "hi TabLineFill         cterm=none      ctermbg=".s:background." ctermfg=".s:text
      " exec "hi VimTitle            cterm=bold      ctermbg=".s:titleBG."    ctermfg=".s:titleText
      " exec "hi VimTitleSep         cterm=none      ctermbg=".s:background." ctermfg=".s:selBG
      " exec "hi VimTitleSepFirst    cterm=none      ctermbg=".s:selBG."      ctermfg=".s:titleBG
      " exec "hi TabLineEnd          cterm=italic    ctermbg=".s:background." ctermfg=".s:text

  "statusline {{{1
    set showmode "show the -- Insert -- at the bottom
    set showcmd
    set laststatus=2 "always show the statusline

    func! GetRelativeFilename()
      let file = expand("%:p")
      if len(file) == 0
        return "[new file]"
      endif
      let dir = getcwd()
      let fileParts = split(file, '/')
      let dirParts = split(dir, '/')
      let nSame = 0
      while nSame < len(fileParts) && nSame < len(dirParts) && fileParts[nSame] == dirParts[nSame]
        let nSame += 1
      endwhile
      let dots = repeat("../", len(dirParts) - nSame)
      return dots . join(fileParts[nSame : len(fileParts)], '/')
    endfunc

    func! GetTerseCwd()
      return fnamemodify(getcwd(), ":~")
    endfunc

    set statusline=
    set statusline+=\ %{GetRelativeFilename()} " file relative to current directory
    set statusline+=\ %m                     " modified flag [+]
    set statusline+=%y                     " filetype
    "set statusline+=:%l:%c                  " line and column
    set statusline+=%=                       " separator... now start on the right side
    set statusline+=\ %<                     " where to truncate if the line is too long
    set statusline+=%{GetTerseCwd()}\        "working dir on the right
"text objects {{{1
   "line (il/al) {{{2
      xnoremap il :<C-U>silent! normal 0v$<CR>
      omap il :normal vil<CR>
      xnoremap al :<C-U>silent! normal! 0v$<CR>
      omap al :normal val<CR>
   "entire file (ie/ae) {{{2
      "todo: is there a difference between il and al?
      xnoremap ie :<C-U>silent! normal ggVG<CR>
      omap ie :normal vie<CR>
      xnoremap ae :<C-U>silent! normal ggVG<CR>
      omap ae :normal vae<CR>
   "indent (ii/ai) {{{2
      xnoremap ii :<C-U>silent call <SID>InIndent(0)<CR>
      omap ii :normal vii<CR>
      xnoremap ai :<C-U>silent call <SID>InIndent(1)<CR>
      omap ai :normal vai<CR>
      "xnoremap ai :<C-U>silent! normal 0v$<CR>
      "omap ai :normal vai<CR>
      func! <SID>InIndent(inclusive)
         let spaceLine = '^\s*$'
         let currentLine = line('.')

         "scan down to find a non-blank line
         while getline(currentLine) =~ spaceLine && currentLine < line('$')
            let currentLine += 1
         endwhile

         let firstLine = currentLine
         let lastLine = currentLine
         let currentIndent = indent(currentLine)

         "find the first line of the selection
         while firstLine > 1 &&
                  \ (indent(firstLine - 1) >= currentIndent
                  \ || getline(firstLine - 1) =~ spaceLine)
            let firstLine -= 1
         endwhile

         "find the last line of the selection
         while lastLine < line('$') &&
                  \ (indent(lastLine + 1) >= currentIndent
                  \ || getline(lastLine + 1) =~ spaceLine)
            let lastLine += 1
         endwhile

         "do the selection
         exec "normal! ".firstLine."gg0V"
         exec "normal! ".lastLine."gg$"

         if a:inclusive
            normal! okoj
         end
      endfunc
  "}}}

  "embedded languages {{{1
  func! HighlightEmbedded(ft, start, end)
    highlight clear HighlightEmbeddedSnip
    "lots of scripts use this variable to bail early
    if exists('b:current_syntax')
      let s:current_syntax = b:current_syntax
      unlet b:current_syntax
    endif

    exec 'syntax include @'.a:ft.' syntax/'.a:ft.'.vim'
    exec 'syntax region sqlString matchgroup=HighlightEmbeddedSnip start=+'.a:start.'+ end=+'.a:end.'+ contains=@'.a:ft
    highlight default HighlightEmbeddedSnip ctermfg=none ctermbg=none

    "reset the value
    if exists('s:current_syntax')
      let b:current_syntax=s:current_syntax
    else
      unlet b:current_syntax
    end
  endfunc

" abolish tildes at end of file {{{1
"hi EndOfBuffer ctermfg=bg ctermbg=bg guifg=bg

