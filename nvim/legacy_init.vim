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

   "zig {{{3
   Plug 'ziglang/zig.vim'
   let g:zig_fmt_autosave = 0

   "colorschemes {{{2
   "Plug 'flazz/vim-colorschemes'
   Plug 'arcticicestudio/nord-vim'
   Plug 'sainnhe/everforest'
   Plug 'trevordmiller/nova-vim'
   Plug 'AlessandroYorba/Arcadia'
   Plug 'jnurmine/Zenburn'
   Plug 'sonph/onehalf', { 'rtp': 'vim' }
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
Plug 'tpope/vim-sleuth'
Plug 'will133/vim-dirdiff'

Plug 'neovim/nvim-lspconfig'
Plug 'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

"Plug 'williamboman/mason.nvim' {{w
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
lua << EOF
table.insert(plugin_setup_funcs, function()
  require"mason".setup()
  require"mason-lspconfig".setup()
end)
EOF

"Plug 'SmiteshP/nvim-navic' {{{2
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
lua << EOF
table.insert(plugin_setup_funcs, function()
  require"nvim-navic".setup {
    icons = {
      File          = "",
      Module        = "",
      Namespace     = "",
      Package       = "",
      Class         = "",
      Method        = "",
      Property      = "",
      Field         = "",
      Constructor   = "",
      Enum          = "",
      Interface     = "",
      Function      = "",
      Variable      = "",
      Constant      = "",
      String        = "",
      Number        = "",
      Boolean       = "",
      Array         = "",
      Object        = "",
      Key           = "",
      Null          = "",
      EnumMember    = "",
      Struct        = "",
      Event         = "",
      Operator      = "",
      TypeParameter = "",
      },
    highlight = false,
    separator = " ➤ ",
    depth_limit = 0,
    depth_limit_indicator = "..",
  }
end)
EOF
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

   "Plug 'terryma/vim-expand-region' {{{2
   " Plug 'terryma/vim-expand-region'
   " xmap v <Plug>(expand_region_expand)

   "Plug 'junegunn/fzf' {{{2
   let g:fzf_buffers_jump = 1
   Plug 'junegunn/fzf'
   Plug 'junegunn/fzf.vim'

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

  local capabilities = require'cmp_nvim_lsp'.default_capabilities(
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
  lspconfig.sumneko_lua.setup {
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        diagnostics = {
          globals = {'vim', 'require'},
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
        telemetry = {
          enable = false,
        },
      },
    }
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
cmp.setup({
  snippet = {
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
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
  "colorscheme zenburn | set bg=light
  "colorscheme arcadia
  "colorscheme onehalfdark
  let g:everforest_background = 'medium'
  let g:everforest_enable_italic = 1
  let g:everforest_ui_contrast = 'low'
  let g:everforest_show_eob = 1
  let g:everforest_diagnostic_text_highlight = 1
  colorscheme everforest | set bg=dark
  "highlight MatchParen cterm=inverse ctermbg=black
  ":NoMatchParen
  let g:loaded_matchparen = 1

  if &diff
    "colorscheme neodark | set bg=dark
    "colorscheme zenburn | set bg=dark
    "colorscheme OceanicNext | set bg=dark
  endif

  nnoremap <f3> :NextColorScheme<cr>
  nnoremap <f2> :PrevColorScheme<cr>
  nnoremap <f1> :RandomColorScheme<cr>
  if mapcheck("<F8>", "n")
    nunmap <F8>
  endif
  "highlight Comment cterm=italic


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


"window/tab manipulation {{{1
  set equalalways "automatically resize windows

  nmap <leader>K <C-W>K
  nmap <leader>J <C-W>J
  nmap <leader>L <C-W>L
  nmap <leader>H <C-W>H

  nmap <leader>w <C-W>

  nmap <leader>tj :call MoveWindowTo#NextTab()<CR>
  nmap <leader>tk :call MoveWindowTo#PrevTab()<CR>
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
    nnoremap <leader>gb :Gitsigns toggle_current_line_blame<cr>
    nnoremap <leader>gB :lua package.loaded.gitsigns.blame_line({full=false,ignore_whitespace=true})<cr>

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
        if &buftype == "terminal"
          bwipe!
        elseif &ft == "netrw"
          q!
        elseif &diff || config
          xa!
        elseif !len(bufname('%'))
          q!
        else
          wq!
        endif
      endfunc
    endif
    let g:MySmartQuitDefined = 1
    nnoremap <M-x> :call MySmartQuit()<cr>
    tnoremap <M-x> :call MySmartQuit()<cr>
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

