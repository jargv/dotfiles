"setup {{{1
  let mapleader = " "
  set shortmess+=I
  let g:isLinux = system('uname') == "Linux\n"
  let g:isMac = !g:isLinux

"plugins {{{1
   "setup Vundle {{{2
      "install setup {{{3
         let vundleDir = expand('~/.vim/bundle/')
         let vundleDoInstall = 0
         if !isdirectory(vundleDir)
            let gitUrl = "https://github.com/gmarik/vundle.git"
            call mkdir(vundleDir)
            exec "!git clone ".gitUrl." ".vundleDir."vundle"
            let vundleDoInstall = 1
         endif
      "normal setup {{{3
         filetype off
         set runtimepath=$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,~/.vim/bundle/vundle
         call vundle#begin()
         Plugin 'gmarik/vundle'
      "}}}
   "}}}

   Plugin 'jargv/vim-go-error-folds'
   Plugin 'ternjs/tern_for_vim'
   Plugin 'cespare/vim-toml'
   Plugin 'trevordmiller/nova-vim'
   Plugin 'pangloss/vim-javascript'
   Plugin 'helino/vim-json'
   Plugin 'Raimondi/delimitMate'
   Plugin 'PeterRincker/vim-argumentative'
   Plugin 'JulesWang/css.vim'
   " Plugin 'artur-shaik/vim-javacomplete2'
   Plugin 'evanmiller/nginx-vim-syntax'
   Plugin 'tpope/vim-repeat'
   Plugin 'ekalinin/Dockerfile.vim'
   Plugin 'rking/ag.vim'
   " Plugin 'diepm/vim-rest-console'
   Plugin 'tpope/vim-obsession'
   Plugin 'reedes/vim-pencil'
   Plugin 'Wolfy87/vim-enmasse'
   " Plugin 'Wolfy87/vim-expand'
   Plugin 'c0r73x/vimdir.vim'
   "Plugin 'chriskempson/base16-vim'
   Plugin 'xolox/vim-misc'
   Plugin 'xolox/vim-colorscheme-switcher'
   "Plugin 'edsono/vim-matchit' TODO: figure out where this went!
   Plugin 'tpope/vim-surround'
   Plugin 'tpope/vim-commentary'
   "Plugin 'altercation/vim-colors-solarized'
   Plugin 'flazz/vim-colorschemes'
   Plugin 'isRuslan/vim-es6'
   " Plugin 'octol/vim-cpp-enhanced-highlight'
   Plugin 'vim-scripts/glsl.vim'
   Plugin 'mattn/emmet-vim'
   Plugin 'ervandew/supertab'
   "Plugin 'junegunn/vim-easy-align' {{{2
     Plugin 'junegunn/vim-easy-align'
     vmap ga <Plug>(EasyAlign)
   "Plugin 'majutsushi/tagbar' {{{2
      Plugin 'majutsushi/tagbar'
      let g:tagbar_left = 1
      "let g:tagbar_vertical = 30
   "Plugin 'guns/vim-sexp' {{{2
      Plugin 'guns/vim-sexp'
      let g:sexp_mappings = {
            \ 'sexp_swap_list_backward':        '<C-k>',
            \ 'sexp_swap_list_forward':         '<C-j>',
            \ 'sexp_swap_element_backward':     '<C-h>',
            \ 'sexp_swap_element_forward':      '<C-l>',
         \ }
   "Plugin 'fatih/vim-go' {{{2
   "
     Plugin 'fatih/vim-go'
     let g:go_fmt_command = "goimports"
     "let g:go_fmt_command = "gofmt"
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
   "Plugin 'jimenezrick/vimerl' {{{2
      "Plugin 'jimenezrick/vimerl'
      "let erlang_force_use_vimerl_indent = 1
   "Plugin 'raichoo/haskell-vim' {{{2
      "let g:haskell_indent_in = 0
      "Plugin 'raichoo/haskell-vim'
   "Plugin 'bitc/vim-hdevtools' {{{2
     "let g:syntastic_haskell_hdevtools_args = '' "'-g-Wall'
     "Plugin 'bitc/vim-hdevtools'
 "}}}
   "Plugin 'eagletmt/ghcmod-vim' {{{2
   "Plugin 'eagletmt/ghcmod-vim'
   "Plugin 'eagletmt/neco-ghc'
 "}}}
   "Plugin 'Shougo/unite.vim' {{{2
      "let g:unite_source_history_yank_enable = 1
       "Plugin 'Shougo/unite.vim'
       "Plugin 'Shougo/vimproc.vim'
       ""todo: try -auto-preview
       "nmap <leader>o :<C-u>Unite -start-insert -no-split -no-resize -auto-preview -vertical-preview file_rec/git<cr>
       "nmap <leader>O :<C-u>Unite -start-insert -no-split -no-resize -auto-preview -vertical-preview file_rec/async<cr>
       "nmap <leader>a :<C-u>Unite -custom-grep-search-word-highlight grep:.<cr>
       "nmap <leader>b :<C-u>Unite -quick-match buffer<cr>
       "nmap <leader>y :<C-u>Unite history/yank<cr>
       "nmap <leader>P :<C-u>Unite process<cr>
       "nmap <leader>s :<C-u>Unite -start-insert source<cr>
       "let g:unite_source_grep_command = 'ag'
       "let g:unite_source_grep_default_opts =
       "  \ '-i --line-numbers --nocolor --nogroup --hidden --ignore ' .
       "  \  '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
       "let g:unite_source_grep_recursive_opt = ''

   "Plugin 'Valloric/YouCompleteMe' {{{2
      command! YouCompleteMeInstall :!cd ~/.vim/bundle/YouCompleteMe && git submodule update --init --recursive && ./install.py --gocode-completer
      "Plugin 'Valloric/YouCompleteMe'
      let g:ycm_min_num_identifier_candidate_chars = 99 "only complete on '.' or '->'
      let g:ycm_min_num_identifier_candidate_chars = 2
      "let g:ycm_filetype_whitelist = { 'cpp': 1, 'hpp': 1 }
      "let g:ycm_global_ycm_extra_conf = '~/config/vim/.ycm_extra_conf.py'
      let g:ycm_show_diagnostics_ui = 0
      "let g:ycm_autoclose_preview_window_after_completion = 1
      let g:ycm_autoclose_preview_window_after_insertion = 1
      let g:ycm_use_ultisnips_completer = 0
      let g:ycm_key_list_select_completion = ['<C-N>']
      let g:ycm_key_list_previous_completion = ['<C-P>']

      let g:ycm_add_preview_to_completeopt = 0
      let g:ycm_min_num_of_chars_for_completion = 1
      let g:ycm_auto_trigger = 1
   "Plugin 'tpope/vim-vinegar' {{{2
     nmap - k
     Plugin 'tpope/vim-vinegar'
     nnoremap <leader>d :Explore<cr>
     nnoremap <leader>D :exec ":e ".getcwd()<cr>
   "Plugin 'jeetsukumaran/vim-filebeagle' {{{2
      " Plugin 'jeetsukumaran/vim-filebeagle'
      " nnoremap <leader>d :FileBeagleBufferDir<cr>
      " nnoremap <leader>D :FileBeagle<cr>
      " let g:filebeagle_suppress_keymaps = 1
      " let g:filebeagle_hijack_netrw = 1
      " nmap <leader>= :vsplit<cr>:FileBeagleBufferDir<cr>
      " nmap <leader>- :split<cr>:FileBeagleBufferDir<cr>

   "Plugin 'jeetsukumaran/vim-buffersaurus' {{{2
   Plugin 'jeetsukumaran/vim-buffersaurus'

   "Plugin 'tpope/vim-fugitive' {{{2
      Plugin 'tpope/vim-fugitive'
      Plugin 'idanarye/vim-merginal'
      augroup Fugitive
         autocmd!
         autocmd BufReadPost fugitive://* set bufhidden=delete
      augroup END
   "Plugin 'scrooloose/syntastic' {{{2
   "Plugin 'scrooloose/syntastic'
     let g:syntastic_error_symbol='✗'
     let g:syntastic_style_error_symbol='✗'
     let g:syntastic_warning_symbol='⚠'
     let g:syntastic_style_warning_symbol='⚠'
     let g:syntastic_mode_map = {
        \ "mode": "passive",
        \ "active_filetypes": [],
        \ "passive_filetypes": [] }
   "Plugin 'vim-scripts/UltiSnips' {{{2
   if !has("nvim")
     Plugin 'vim-scripts/UltiSnips'
   end
      let g:UltiSnipsExpandTrigger="<tab>"
      let g:UltiSnipsJumpForwardTrigger="<tab>"
      let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

      let g:UltiSnipsEditSplit = 'vertical'
      let g:UltiSnipsSnippetsDir = '~/config/vim/my_snippets'

      let g:UltiSnipsSnippetDirectories=["my_snippets"]

      map <leader>s :UltiSnipsEdit<CR>

   "Plugin 'terryma/vim-expand-region' {{{2
   Plugin 'terryma/vim-expand-region'
      "todo: add my text objects here
      vmap v <Plug>(expand_region_expand)
   "Plugin 'Lokaltog/vim-easymotion' {{{2
   Plugin 'easymotion/vim-easymotion'
      let g:EasyMotion_do_mapping = 0

      map <leader>f <Plug>(easymotion-s)

      let g:EasyMotion_keys = 'abcdefghijklmnopqrstuvwxyz'
      let g:EasyMotion_do_shade = 0
   "Plugin 'benmills/vimux' {{{2
      Plugin 'benmills/vimux'
      let g:VimuxHeight = 30
      let VimuxUseNearest = 1
   "Plugin 'godlygeek/tabular' {{{2
   Plugin 'godlygeek/tabular'
      "todo: find a new mapping for this shiz
      "nnoremap <leader>= :Tabular /=/<CR>:echo<CR>
   "Plugin 'scrooloose/nerdtree' {{{2
   "Plugin 'scrooloose/nerdtree'
   "   let NERDTreeDirArrows=1
   "   let NERDTreeMinimalUI=1
   "   let NERDTreeCascadeOpenSingleChildDir=1
   "   let NERDTreeAutoDeleteBuffer=1
   "   let NERDTreeAutoCenter=1
   "   let NERDTreeQuitOnOpen=1
   "   nmap <leader>D :exec "NERDTreeToggle "<CR>
   "   nmap <leader>d :exec "NERDTreeFind "<CR>

   "Plugin 'airblade/vim-gitgutter' {{{2
   let g:gitgutter_sign_added = '+'
   let g:gitgutter_sign_modified = '~'
   let g:gitgutter_sign_removed = 'x'
   let g:gitgutter_sign_modified_removed = '%'
   let g:gitgutter_diff_args = '-w'

   if !exists('g:gitgutter_enabled')
     let g:gitgutter_enabled = 1
     let g:MarkingToolsState = ''
   endif
   let g:gitgutter_map_keys = 0
   highlight clear SignColumn
   Plugin 'airblade/vim-gitgutter'
      nnoremap <leader>gu :GitGutterToggle<cr>
      "nnoremap <leader>gg :call MarkingToolsToggle()<cr><cr>
      func! MarkingToolsToggle()
         if g:MarkingToolsState == 'syntastic'
           SyntasticToggleMode
           GitGutterEnable
           let g:MarkingToolsState = 'gitgutter'
         elseif g:MarkingToolsState == 'gitgutter'
           GitGutterDisable
           SyntasticToggleMode
           SyntasticCheck
           let g:MarkingToolsState = ''
         else
           SyntasticT
           let g:MarkingToolsState = 'syntastic'
         endif
         echo g:MarkingToolsState
      endfunc
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
            GitGutterNextHunk
            normal zz
          else
            GitGutterPrevHunk
            normal zz
          endif
        endif
      endfunc
      nnoremap gn :call GitAdjacentChange(1)<cr>
      nnoremap gp :call GitAdjacentChange(0)<cr>
      nnoremap gr :GitGutterRevertHunk<CR>
      nnoremap gs :GitGutterStageHunk<CR>
   "}}}

  "Run the setup! {{{2
    call vundle#end()
    "my shiz should override EVERYTHING
    set runtimepath-=~/.vim "remove first so that the add occurs at the end
    set runtimepath+=~/.vim
    filetype plugin indent on
    if vundleDoInstall
        BundleInstall!
    endif
  "}}}

  "colorschemes {{{1
  set termguicolors
  set t_ut= "fix the weird background erasing crap
  set ttyfast
  if g:isMac
    colorscheme southwest-fog
  elseif g:isLinux
    colorscheme nova
  endif

  nnoremap <f3> :NextColorScheme<cr>
  nnoremap <f2> :PrevColorScheme<cr>
  nnoremap <f1> :RandomColorScheme<cr>
  highlight Comment cterm=italic

"prototype settings {{{1
  nnoremap <leader>, :TagbarOpenAutoClose<cr>
  nnoremap <leader>y [sciw<esc>:echo @"<cr>a

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
    nnoremap <C-L> :nohlsearch<CR><C-L>
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
    nnoremap <silent> <F4> :set spell!<cr>:set spell?<cr>
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
        highlight TrailingWhitespace cterm=underline
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
  "other {{{2
    let g:filetype_pl="prolog"
    set scrolloff=1
    set nofileignorecase
    set virtualedit=block "allow moving onto whitespace during block select
    set noreadonly "I never really care about using readonly
    set wildmenu autowrite autowriteall
    set backspace=indent,eol,start
    set switchbuf=useopen,usetab
    set showbreak=...
    set undofile hidden history=1000 " keep undo history in buffers when not visible/open
    set completeopt=menuone,noinsert
    set mouse=a
    set nowrap
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
    let ft = &filetype
    tabedit ~/config/dotfiles/vimrc.vim

    if !empty(ft)
      exec "vsplit ~/.vim/ftplugin/".ft.".vim"
    endif

    cd ~/config
  endfunc
  augroup ConfigReload
      au!
      autocmd bufwritepost *.vim call <SID>reloadConfig()
  augroup end

  if !exists('*<SID>reloadConfig')
    func <SID>reloadConfig()
      silent source ~/.vimrc
      silent source ~/config/vim/plugin/fquery.vim
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
  endfunc

  "autocommand on save
  augroup MakeOnSaveGroup
     autocmd!
     autocmd BufWritePost * :if g:makeOnSave | call <SID>RunMake() | endif
  augroup END

  "ensure the variables always exist
  if !exists("g:makeTarget") || !exists("g:makeBuildtool")
    call <SID>InitMyMake()
  endif

  nnoremap <leader>m :cclose<CR>:call <SID>RunMake()<CR><CR><CR>
  nnoremap <leader>MM :call <SID>DetectBuildTool()<cr>

  nnoremap <leader>Mt :let g:makeTarget = input(">", g:makeTarget)<CR>
  nnoremap <leader>Mr :let g:runTarget = input(">", g:runTarget)<CR>
  nnoremap <leader>Md :let g:makeDirectory = input(">", len(g:makeDirectory) ? (g:makeDirectory) : getcwd())<CR>
  nnoremap <leader>Mx :let g:makeBuildtool = input(">", g:makeBuildtool)<cr>
  nnoremap <leader>E :let g:closeOnCollectErrors = !g:closeOnCollectErrors<CR>:echo (g:closeOnCollectErrors ? "CLOSE" : "DON'T CLOSE")<CR>
  nnoremap <leader>e :if g:closeOnCollectErrors<CR>VimuxCloseRunner<CR>endif<CR>:exec "cfile /tmp/vim-errors-".&filetype<CR>:cw<CR><CR>

  nnoremap <leader>Ms :call <SID>ToggleMakeOnSave()<cr>
  nnoremap <leader>Mb :call <SID>ToggleReloadBrowserOnMake()<cr>
  nnoremap <leader>Mp :let g:browserReloadPort = input('Port:', g:browserReloadPort ? g:browserReloadPort : '')<cr>

  func! <SID>ToggleReloadBrowserOnMake()
    if !g:browserReloadOnMake
      echom "Reload on save [ON]"
    else
      echom "Reload on save: [OFF]"
      let g:browserReloadArgs = ""
    endif
    let g:browserReloadOnMake = !g:browserReloadOnMake
  endfunc

  func! <SID>ToggleMakeOnSave()
     let g:makeOnSave = !g:makeOnSave
     if g:makeOnSave
        echo "Make on Save [ON]"
     else
        echo "Make on Save [OFF]"
     endif
  endfunc

  func! <SID>DetectBuildTool()
    call <SID>InitMyMake()
    let g:makeOnSave = 1
    let g:makeDirectory = getcwd()
    if filereadable("build.ninja")
      let g:makeBuildtool = "ninja"
    elseif len(glob('*.xcodeproj'))
      let g:makeBuildtool = "xcodebuild"
    elseif filereadable("CMakeLists.txt") && isdirectory("build")
      cd build
      call <SID>DetectBuildTool()
      return
    elseif filereadable("CMakeLists.txt")
      call VimuxRunCommand("mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=DEBUG ..")
      return
    elseif expand('%:e') == "go"
      let gopath = $GOPATH
      let testExt = "_test.go"
      let file = expand('%:p')
      if file[-len(testExt):] == testExt
        let g:makeBuildtool = "go test"
        let g:makeTarget = ""
      elseif file[0 : len(gopath) - 1] == gopath
        let g:makeBuildtool = "go install"
        let g:makeTarget = expand('%:p:h')[len($GOPATH . "/src/"):]
      else
        let g:makeBuildtool = "go run"
        let g:makeTarget = expand('%')
      endif
    elseif len(glob('*.cabal'))
      let g:makeBuildtool = "cabal"
      let g:makeTarget = expand('run')
    elseif expand('%:e') == "hs"
      let g:makeBuildtool = "runhaskell"
      let g:makeTarget = expand('%')
    elseif filereadable("webpack.config.js")
      let g:makeBuildtool = "webpack"
      let g:makeTarget = ""
    elseif filereadable("project.clj")
      let g:makeBuildtool = "lein"
      let g:makeTarget = "run"
    elseif expand('%:e') == "ts"
      let g:makeBuildtool = "tsc"
      let g:makeTarget = expand('%')
    elseif filereadable("build.gradle")
      let g:makeBuildtool = "gradle"
      let g:makeTarget = "build"
    elseif filereadable("Makefile") || filereadable("makefile")
      let g:makeBuildtool = "make"
    else
       "just try to execute the file
       let g:makeBuildTool = ""
       let g:makeTarget = "./".expand('%')
    endif
    call VimuxRunCommand('echo "detected> '.g:makeBuildtool.' '.g:makeTarget.'"')
  endfunc

  func! <SID>RunMake()
    call VimuxRunCommand("set -o pipefail")
    let ran = 0
    wa
    if len(g:makeBuildtool) || len(g:makeTarget)
      let ran = 1
      :VimuxInterruptRunner
      let cmd = g:makeBuildtool." ".g:makeTarget." 2>&1 |tee /tmp/vim-errors-".&filetype
      if len(g:runTarget)
        let cmd = cmd." && ".g:runTarget
      endif
      call VimuxRunCommand("cd ".g:makeDirectory." && ".cmd)
      normal 
    endif
    if g:browserReloadPort
      let ran = 1
      let triesRemaining = 100
      let success = 0
      while !success && triesRemaining
        call system("curl -f -s localhost:".g:browserReloadPort)
        let success = !v:shell_error
        let triesRemaining -= 1
      endwhile
      if !success
        echom "ERROR: Could not restart the server :("
        return
      endif
    endif
    if g:browserReloadOnMake
      let ran = 1
      if executable("xdotool") && empty(g:browserReloadArgs)
        let g:browserReloadArgs = system("xdotool selectwindow")
      endif
      call system(g:browserReloadCommand . " " . g:browserReloadArgs)
    endif
    if !ran
       echo "no buildtool set up"
    endif
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


"mappings {{{1
  "better defaults {{{2
    nnoremap p p=`]
    nnoremap <c-p> p
    nnoremap == ==j
    nnoremap 0 ^
    nnoremap Y y$
    vnoremap R r<space>R
    vnoremap & :&<cr>
    nnoremap * :let @/ = '\<'.expand("<cword>").'\>'<CR>:set hlsearch<CR>:echo<CR>
    "todo: make this work
    "vnoremap * :let @/ = '\<'.expand("<cword>").'\>'<CR>:set hlsearch<CR>:echo<CR>

  "control-move text{{{2
    vnoremap <C-j> xp'[V']
    vnoremap <C-k> xkP'[V']
  "external applications {{{2
    nnoremap <leader>. :!tmux split-window -p20 <CR><CR>
    if has("nvim")
      nnoremap <leader>. :split term://zsh<cr>:startinsert<cr>
    end
  "git mappings {{{2
    nnoremap <leader>gD :!git difftool -w<CR>
    nnoremap <leader>gd :!git difftool -w %<CR><CR>
    nnoremap <leader>gc :!git bedone<CR><CR>
    nnoremap <leader>gC :!tig refs<cr><cr>
    nnoremap <leader>gi :!git rebase -i<CR>
    nnoremap <leader>gl :!git log <CR><CR>
    nnoremap <leader>gh :!git hist --all <CR><CR>
    nnoremap <leader>gH :!git hist<CR><CR>
    nnoremap <leader>gb :Gblame w<CR>
    nnoremap <leader>gs :!tig status<CR><CR>
    nnoremap <leader>gg :exec ":!git ".input("git> ")<CR>
  "working directory mappings {{{2
    nnoremap <leader>U :cd %:p:h<CR>:echo<CR>
    nnoremap <leader>u :cd ..<CR>:echo<CR>


  "make use of Q for quick system-clipboard copying{{{2
    nnoremap Q ggVG
    vnoremap Q "+y
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
          if &diff || !len(bufname('%'))
              xa!
          else
              wq!
          endif
        endfunc
        echo
    endif
    let g:MySmartQuitDefined = 1
    nnoremap <leader>q :call MySmartQuit()<CR>
    nnoremap <leader>Q :cquit!<CR>
    nnoremap <leader><leader> :w<CR>
    nnoremap <leader>X :xa!<CR>
    nnoremap <leader>x :echo<CR>

  "window/tab manipulation {{{2
    nmap <leader>= :Sexplore!<cr>
    nmap <leader>- :Sexplore<cr>

    nnoremap <leader>v :vsplit<cr>
    nnoremap <leader>V :split<cr>

    nmap <leader>k <c-w>k
    nmap <leader>j <c-w>j
    nmap <leader>l <c-w>l
    nmap <leader>h <c-w>h

    nmap <leader>K <C-W>K
    nmap <leader>J <C-W>J
    nmap <leader>L <C-W>L
    nmap <leader>H <C-W>H

    nmap <leader>w <C-W>

    nmap <leader>tt <C-W>T
    nmap <leader>tl gt
    nmap <leader>th gT
    nmap <leader>tj :call MoveWindowTo#NextTab()<CR>
    nmap <leader>tk :call MoveWindowTo#PrevTab()<CR>
    nmap <leader>tn :$tabnew<CR>
    nmap <leader>tc :tabclose <CR>
    nmap <leader>to :tabonly<CR>

    nmap <leader><Down> <C-W>+
    nmap <leader><Up> <C-W>-
    nmap <leader><Left> <C-W><
    nmap <leader><Right> <C-W>>
    nmap <Down>  5<C-W>+
    nmap <Up>    5<C-W>-
    nmap <Left>  5<C-W><
    nmap <Right> 5<C-W>>

  "next and previous location/error/vimgrep {{{2
    nnoremap <expr> <silent> <leader>n ((len(getqflist()) ? ":cn" : ":lnext")."<CR>")
    nnoremap <expr> <silent> <leader>p ((len(getqflist()) ? ":cp" : ":lprev")."<CR>")
  "K as the opposite of Join {{{2
    vnoremap <silent> K <Nop>
    nnoremap <silent> K :call <SID>Format() <CR>
    func! <SID>Format()
        normal Vgq
    endfunc
  "learn more vim! {{{2
    nnoremap <leader><F3> :tabe ~/config/vim/bookmark.vim<cr> :source %<cr><cr>

  "incr/decr then save{{{2
    noremap  :w<CR>
    noremap  :w<CR>

  "smart enter key "{{{2
    inoremap <expr> <CR> SmartEnter()
    func! SmartEnter()
      "select from the popup menu if it's visible
      if pumvisible()
        return "\<C-y>"
      endif

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
          return 'O'
        else
          return ''
        endif
      elseif len(restOfLine) == 0
        if     lastChar == '{' | return '}O'
        elseif lastChar == '(' | return ')O'
        elseif lastChar == '[' | return ']O'
        else                   | return ''
        endif
      endif
      return "" "'O'
    endfunc
  "my plugins {{{2
    nmap <leader>o :Fquery<CR>
  " get the styles under the cursor {{{2
    map <leader>S :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
  "}}}

   "terminal colorschemes {{{1
   "set t_Co=256
   ""Solorized options {{{2
   "   let g:solarized_termtrans = 1
   "   "let g:solarized_termcolors = 256
   "   let g:solarized_contrast="normal"    "default value is normal
   "   let g:solarized_visibility="normal"  "default value is normal
   ""}}}

   "let g:isSeafoamOrBlazer = 0
   "let g:isSymfonic = 0
   "let g:oceanDark = 0 "isLinux || isMac
   "let g:oceanLight = 1
   "let g:codeSchool = 0
   "let g:atelierlakeside_light = 0
   "let g:atelierlakeside_dark = 0
   "let g:solarized_dark = 0
   "let g:solarized_light = 0

   ""colorscheme tweaks {{{2
   " if g:atelierlakeside_light "{{{3
   "   colorscheme adam
   "   "tabline {{{4
   "      let s:background = 7
   "      let s:text       = 12
   "      let s:selText    = 8
   "      let s:titleText  = 4
   "      let s:selBG      = 15
   "      let s:titleBG    = 7
   "   "}}}
   "   "git gutter {{{4
   "     highlight GitGutterAdd          ctermbg=4 ctermfg=7 " an added line
   "     highlight GitGutterChange       ctermbg=4 ctermfg=7 " a changed line
   "     highlight GitGutterDelete       ctermbg=4 ctermfg=7 " at least one removed line
   "     highlight GitGutterChangeDelete ctermbg=4 ctermfg=7 " a changed line followed by at least one removed line
   "     highlight SignColumn            ctermbg=4 ctermfg=7
   "   "}}}
   "   "diffs {{{4
   "     highlight DiffAdd ctermbg=16 "change
   "     highlight DiffDelete ctermbg=16 ctermfg=2
   "     highlight DiffChange ctermbg=16 ctermfg=none cterm=none
   "     highlight DiffText ctermbg=12 ctermfg=16 cterm=none
   "   "}}}

   "   highlight VertSplit ctermbg=4 ctermfg=4
   "   highlight LineNr ctermbg=4 ctermfg=7 cterm=none
   "   highlight NonText ctermfg=39
   "   highlight Search ctermbg=15 cterm=underline,bold
   "   highlight Folded ctermbg=none ctermfg=24 cterm=underline
   "   highlight Visual ctermbg=16 term=none cterm=none ctermfg=none
   "   highlight StatusLine ctermbg=7 ctermfg=8 cterm=underline
   "   highlight StatusLineNC ctermbg=7 ctermfg=8 cterm=underline
   "   highlight StatusLineBold ctermbg=7 ctermfg=23 cterm=underline
   "   highlight MatchParen ctermbg=15 ctermfg=10 cterm=bold
   "   highlight CursorLine cterm=none ctermbg=none
   "   highlight CursorLineNR cterm=bold ctermfg=15 ctermbg=4
   "   highlight Pmenu ctermbg=4 ctermfg=0
   "   highlight Pmenusel ctermbg=13 ctermfg=16

   " elseif g:atelierlakeside_dark "{{{3
   " colorscheme adam
   " "colorscheme Chasing_Logic
   " "colorscheme 256-grayvim
   "   "tabline {{{4
   "      let s:background = 10
   "      let s:text       = 7
   "      let s:selText    = 5
   "      let s:selBG      = 0
   "      let s:titleText  = 13
   "      let s:titleBG    = 10
   "   "}}}
   "   "git gutter {{{4
   "     highlight GitGutterAdd          ctermbg=16 ctermfg=22 " an added line
   "     highlight GitGutterChange       ctermbg=16 ctermfg=5 " a changed line
   "     highlight GitGutterDelete       ctermbg=16 ctermfg=6 " at least one removed line
   "     highlight GitGutterChangeDelete ctermbg=16 ctermfg=0 " a changed line followed by at least one removed line
   "     highlight SignColumn            ctermbg=16 ctermfg=0
   "   "}}}
   "   "diffs {{{4
   "     highlight DiffAdd    ctermbg=16 "change
   "     highlight DiffDelete ctermbg=16 ctermfg=2
   "     highlight DiffChange ctermbg=16 ctermfg=none cterm=none
   "     highlight DiffText   ctermbg=8 ctermfg=16 cterm=none
   "     highlight FoldColumn ctermbg=10 ctermfg=0
   "   "}}}
   "   highlight VertSplit ctermbg=0 ctermfg=10
   "   highlight LineNr ctermbg=16 ctermfg=10 cterm=none
   "   highlight NonText ctermfg=0
   "   highlight Search ctermbg=10 cterm=none
   "   highlight Folded ctermbg=none ctermfg=24 cterm=underline
   "   highlight Visual ctermbg=10 term=none cterm=none ctermfg=none
   "   highlight StatusLine ctermbg=10 ctermfg=13 cterm=underline
   "   highlight StatusLineNC ctermbg=10 ctermfg=13 cterm=underline
   "   highlight StatusLineBold ctermbg=10 ctermfg=5 cterm=underline
   "   highlight MatchParen ctermbg=2 ctermfg=13 cterm=bold
   "   highlight CursorLine cterm=none ctermbg=none
   "   highlight CursorLineNR cterm=bold,underline ctermfg=0 ctermbg=13
   "   highlight Pmenu ctermbg=11 ctermfg=16
   "   highlight Pmenusel ctermbg=13 ctermfg=16

   " elseif g:codeSchool "{{{3
   "   colorscheme DevC++
   "   "tabline {{{4
   "      let s:background = 16
   "      let s:text       = 8
   "      let s:selText    = 4
   "      let s:titleText  = 3
   "      let s:selBG      = 0
   "      let s:titleBG    = 16
   "   "}}}
   "   "git gutter {{{4
   "     highlight GitGutterAdd          ctermbg=16 ctermfg=22 " an added line
   "     highlight GitGutterChange       ctermbg=16 ctermfg=5 " a changed line
   "     highlight GitGutterDelete       ctermbg=16 ctermfg=6 " at least one removed line
   "     highlight GitGutterChangeDelete ctermbg=16 ctermfg=0 " a changed line followed by at least one removed line
   "   "}}}
   "   "diffs {{{4
   "     highlight DiffAdd ctermbg=16 "change
   "     highlight DiffDelete ctermbg=16 ctermfg=2
   "     highlight DiffChange ctermbg=16 ctermfg=none cterm=none
   "     highlight DiffText ctermbg=12 ctermfg=16 cterm=none
   "   "}}}

   "   highlight VertSplit ctermbg=4 ctermfg=16
   "   highlight LineNr ctermbg=16 ctermfg=0 cterm=none
   "   highlight SignColumn ctermbg=16 ctermfg=0
   "   highlight NonText ctermbg=0 ctermfg=39
   "   highlight Search ctermbg=12 ctermfg=16 cterm=none
   "   highlight Folded ctermbg=none ctermfg=24 cterm=underline
   "   highlight Visual ctermbg=16 term=none cterm=none ctermfg=none
   "   highlight StatusLine ctermbg=16 ctermfg=2 cterm=bold
   "   highlight StatusLineNC ctermbg=16 ctermfg=8 cterm=none
   "   highlight StatusLineBold ctermbg=16 ctermfg=14 cterm=none
   "   highlight MatchParen ctermbg=16 ctermfg=15
   "   highlight CursorLine cterm=none ctermbg=none
   "   highlight CursorLineNR cterm=bold,underline ctermfg=red
   "   highlight Pmenu ctermbg=16 ctermfg=1
   "   highlight Pmenusel ctermbg=1 ctermfg=16

   " elseif g:codeSchool "{{{3
   "   "tabline {{{4
   "      let s:background = 16
   "      let s:text       = 8
   "      let s:selText    = 4
   "      let s:titleText  = 3
   "      let s:selBG      = 0
   "      let s:titleBG    = 16
   "   "}}}
   "   "git gutter {{{4
   "     highlight GitGutterAdd          ctermbg=16 ctermfg=22 " an added line
   "     highlight GitGutterChange       ctermbg=16 ctermfg=5 " a changed line
   "     highlight GitGutterDelete       ctermbg=16 ctermfg=6 " at least one removed line
   "     highlight GitGutterChangeDelete ctermbg=16 ctermfg=0 " a changed line followed by at least one removed line
   "   "}}}
   "   "diffs {{{4
   "     highlight DiffAdd ctermbg=16 "change
   "     highlight DiffDelete ctermbg=16 ctermfg=2
   "     highlight DiffChange ctermbg=16 ctermfg=none cterm=none
   "     highlight DiffText ctermbg=12 ctermfg=16 cterm=none
   "   "}}}

   "   highlight VertSplit ctermbg=4 ctermfg=16
   "   highlight LineNr ctermbg=16 ctermfg=0 cterm=none
   "   highlight SignColumn ctermbg=16 ctermfg=0
   "   highlight NonText ctermbg=0 ctermfg=39
   "   highlight Search ctermbg=12 ctermfg=16 cterm=none
   "   highlight Folded ctermbg=none ctermfg=24 cterm=underline
   "   highlight Visual ctermbg=16 term=none cterm=none ctermfg=none
   "   highlight StatusLine ctermbg=16 ctermfg=2 cterm=bold
   "   highlight StatusLineNC ctermbg=16 ctermfg=8 cterm=none
   "   highlight StatusLineBold ctermbg=16 ctermfg=14 cterm=none
   "   highlight MatchParen ctermbg=16 ctermfg=15
   "   highlight CursorLine cterm=none ctermbg=none
   "   highlight CursorLineNR cterm=bold,underline ctermfg=red
   "   highlight Pmenu ctermbg=16 ctermfg=1
   "   highlight Pmenusel ctermbg=1 ctermfg=16

   " elseif g:oceanDark "{{{3
   "   colorscheme blazer
   "   "tabline {{{4
   "      let s:background = 16
   "      let s:text       = 8
   "      let s:selText    = 6
   "      let s:titleText  = 14
   "      let s:selBG      = 0
   "      let s:titleBG    = 16
   "   "}}}
   "   "git gutter {{{4
   "     highlight GitGutterAdd          ctermbg=16 ctermfg=22 " an added line
   "     highlight GitGutterChange       ctermbg=16 ctermfg=5 " a changed line
   "     highlight GitGutterDelete       ctermbg=16 ctermfg=6 " at least one removed line
   "     highlight GitGutterChangeDelete ctermbg=16 ctermfg=0 " a changed line followed by at least one removed line
   "   "}}}
   "   "diffs {{{4
   "      highlight DiffAdd ctermbg=8 "change
   "      highlight DiffDelete ctermbg=16 ctermfg=2
   "      highlight DiffChange ctermbg=16 ctermfg=none cterm=none
   "      highlight DiffText ctermbg=12 ctermfg=16 cterm=none
   "   "}}}
   "   highlight VertSplit ctermbg=3 ctermfg=16
   "   highlight LineNr ctermbg=16 ctermfg=8 cterm=none
   "   highlight SignColumn ctermbg=16 ctermfg=16
   "   highlight NonText ctermbg=none ctermfg=39
   "   highlight Search ctermbg=12 ctermfg=16 cterm=none
   "   highlight Folded ctermbg=none ctermfg=24 cterm=underline
   "   highlight Visual ctermbg=16 term=none cterm=none ctermfg=none
   "   highlight StatusLine ctermbg=16 ctermfg=2 cterm=bold
   "   highlight StatusLineNC ctermbg=16 ctermfg=8 cterm=none
   "   highlight StatusLineBold ctermbg=16 ctermfg=14 cterm=none
   "   highlight MatchParen ctermbg=16 ctermfg=15
   "   highlight CursorLine cterm=none ctermbg=none
   "   highlight CursorLineNR cterm=bold,underline ctermfg=red
   "   highlight Pmenu ctermbg=4 ctermfg=0
   "   highlight Pmenusel ctermbg=0 ctermfg=4
   " elseif g:oceanLight "{{{3
   "   colorscheme oceanlight
   "   "git gutter {{{4
   "     highlight GitGutterAdd          ctermbg=16 ctermfg=22 " an added line
   "     highlight GitGutterChange       ctermbg=16 ctermfg=5 " a changed line
   "     highlight GitGutterDelete       ctermbg=16 ctermfg=6 " at least one removed line
   "     highlight GitGutterChangeDelete ctermbg=16 ctermfg=0 " a changed line followed by at least one removed line
   "   "}}}
   "   "tabline {{{4
   "       let s:background = 0
   "       let s:text       = 8
   "       let s:selText    = 6
   "       let s:titleText  = 14
   "       let s:selBG      = 0
   "       let s:titleBG    = 16
   "   "diff {{{4
   "     highlight DiffAdd ctermbg=7
   "     highlight DiffDelete ctermbg=7 ctermfg=4
   "     highlight DiffChange ctermbg=7 ctermfg=none cterm=none
   "     highlight DiffText ctermbg=10 ctermfg=16 cterm=none
   "   "}}}
   "   highlight VertSplit ctermbg=3 ctermfg=16
   "   highlight LineNr ctermbg=16 ctermfg=8 cterm=none
   "   highlight SignColumn ctermbg=16 ctermfg=16
   "   highlight NonText ctermbg=none ctermfg=39
   "   highlight Search ctermbg=12 ctermfg=16 cterm=none
   "   highlight Folded ctermbg=0 ctermfg=7 cterm=none
   "   highlight Visual ctermbg=7 term=none cterm=none ctermfg=none
   "   highlight StatusLine ctermbg=16 ctermfg=2 cterm=bold
   "   highlight StatusLineNC ctermbg=16 ctermfg=8 cterm=none
   "   highlight StatusLineBold ctermbg=16 ctermfg=14 cterm=none
   "   highlight MatchParen ctermbg=3 ctermfg=none cterm=none
   "   highlight CursorLine cterm=none ctermbg=none
   "   highlight CursorLineNR cterm=bold,underline ctermfg=red
   "   highlight Pmenu ctermbg=4 ctermfg=7
   "   highlight Pmenusel ctermbg=13 ctermfg=16

   "elseif g:isSymfonic "{{{3
   "  set bg=dark
   "  colorscheme solarized
   "   "tabline
   "      let s:background = 8
   "      let s:text       = 12
   "      let s:selText    = 4
   "      let s:selBG      = 16
   "      let s:titleText  = 22
   "      let s:titleBG    = 8
   "   highlight VertSplit ctermbg=8
   "   highlight LineNr ctermbg=8 ctermfg=16
   "   highlight SignColumn ctermbg=0 ctermfg=16
   "   highlight NonText ctermbg=0 ctermfg=39
   "   highlight Search ctermbg=white ctermfg=4
   "   highlight Folded ctermbg=none ctermfg=24 cterm=underline
   "   highlight Visual ctermbg=8 term=none cterm=none ctermfg=none
   "   highlight StatusLine ctermbg=8 ctermfg=24 cterm=bold
   "   highlight StatusLineNC ctermbg=8 ctermfg=24 cterm=bold
   "   highlight StatusLineBold ctermbg=8 ctermfg=1 cterm=bold
   "   highlight MatchParen ctermbg=16 ctermfg=0 cterm=underline
   "   highlight CursorLine cterm=none ctermbg=none
   "   highlight CursorLineNR cterm=bold ctermfg=red cterm=underline
   "   highlight DiffAdd ctermbg=8
   "   highlight DiffDelete ctermbg=8 ctermfg=24
   "   highlight DiffChange ctermbg=8 cterm=none
   "   highlight DiffText ctermbg=17 ctermfg=24 cterm=none "add
   "elseif g:isSeafoamOrBlazer "{{{3
   "   "tabline
   "      let s:background = 7
   "      let s:text       = 4
   "      let s:selText    = 109
   "      let s:selBG      = "white"
   "      let s:titleText  = 24
   "      let s:titleBG    = 7
   "      let s:tabSep     = 7
   "   highlight VertSplit ctermbg=16
   "   "highlight LineNr ctermbg=none ctermfg=59
   "   highlight LineNr ctermbg=none ctermfg=4 ctermbg=16
   "   highlight SignColumn ctermbg=none ctermfg=12
   "   highlight NonText ctermbg=none ctermfg=39
   "   highlight Search ctermbg=white ctermfg=4
   "   highlight Folded ctermbg=none ctermfg=24 cterm=underline
   "   highlight Visual ctermbg=16 term=none cterm=none ctermfg=none
   "   highlight StatusLine ctermbg=16 ctermfg=24 cterm=bold
   "   highlight StatusLineNC ctermbg=16 ctermfg=24 cterm=bold
   "   highlight StatusLineBold ctermbg=16 ctermfg=12 cterm=bold
   "   highlight MatchParen ctermbg=black ctermfg=white
   "   highlight CursorLine cterm=bold ctermbg=none
   "   highlight CursorLineNR cterm=bold ctermfg=red
   "   highlight DiffAdd ctermbg=16
   "   highlight DiffDelete ctermbg=16 ctermfg=24
   "   highlight DiffChange ctermbg=16 cterm=none
   "   highlight DiffText ctermbg=17 ctermfg=24 cterm=none
   "elseif g:solarized_dark "{{{3
   "   colorscheme solarized
   "   set bg=dark
   "   "tabline {{{4
   "      let s:background = 16
   "      let s:text       = 12
   "      let s:selText    = 4
   "      let s:selBG      = "none"
   "      let s:titleText  = 24
   "      let s:titleBG    = 16
   "      "}}}
   "   highlight VertSplit ctermbg=black
   "   highlight LineNr ctermbg=0 ctermfg=6
   "   highlight NonText ctermfg=4
   "   highlight Search ctermbg=8 ctermfg=4
   "   highlight SignColumn ctermbg=black ctermfg=4
   "   highlight Folded ctermbg=black ctermfg=6 cterm=bold
   "   highlight Visual ctermbg=16 term=none cterm=none ctermfg=none
   "   highlight MatchParen ctermbg=black ctermfg=white
   "   highlight StatusLine ctermfg=black ctermbg=white
   "   highlight StatusLineNC ctermbg=12 ctermfg=black
   "   highlight StatusLineBold ctermfg=black ctermbg=4 cterm=bold,reverse
   "elseif g:solarized_light "{{{3
   "   colorscheme solarized
   "   set bg=light
   "   "tabline {{{4
   "      let s:background = 24
   "      let s:text       = 7
   "      let s:selText    = 0
   "      let s:titleText  = 4
   "      let s:selBG      = "white"
   "      let s:titleBG    = 24
   "   "}}}
   "   "git gutter {{{4
   "     highlight GitGutterAdd          ctermbg=24 ctermfg=2 " an added line
   "     highlight GitGutterChange       ctermbg=24 ctermfg=4 " a changed line
   "     highlight GitGutterDelete       ctermbg=24 ctermfg=1 " at least one removed line
   "     highlight GitGutterChangeDelete ctermbg=24 ctermfg=7 " a changed line followed by at least one removed line
   "     highlight SignColumn            ctermbg=24 ctermfg=7
   "   "}}}
   "   "diffs {{{4
   "     highlight DiffAdd ctermbg=16 "change
   "     highlight DiffDelete ctermbg=16 ctermfg=2
   "     highlight DiffChange ctermbg=16 ctermfg=none cterm=none
   "     highlight DiffText ctermbg=12 ctermfg=16 cterm=none
   "   "}}}

   "   highlight VertSplit ctermbg=24 ctermfg=4
   "   highlight LineNr ctermbg=24 ctermfg=7 cterm=none
   "   highlight NonText ctermfg=39
   "   highlight Search ctermbg=15 cterm=underline,bold
   "   highlight Folded ctermbg=none ctermfg=24 cterm=underline
   "   highlight Visual ctermbg=16 term=none cterm=none ctermfg=none
   "   highlight StatusLine ctermbg=24 ctermfg=7 cterm=none
   "   highlight StatusLineNC ctermbg=24 ctermfg=4 cterm=none
   "   highlight StatusLineBold ctermbg=24 ctermfg=4 cterm=none
   "   highlight MatchParen ctermbg=15 ctermfg=10 cterm=bold
   "   highlight CursorLine cterm=none ctermbg=none
   "   highlight CursorLineNR cterm=bold ctermfg=15 ctermbg=4
   "   highlight Pmenu ctermbg=4 ctermfg=0
   "   highlight Pmenusel ctermbg=13 ctermfg=16
   " endif
   ""}}}
"cursor {{{1
   "use the cursorline as mode indicator {{{2
      " autocmd InsertEnter * set cursorline
      " autocmd InsertLeave * set nocursorline
      " highlight CursorLine cterm=none
      " set nocursorline
      "
   "change cursor shape in the terminal {{{2
      if g:isLinux
        augroup LinuxCursor
          au!
          au VimEnter,InsertLeave * silent execute '!echo -ne "\e[2 q"' | redraw!
          au InsertEnter,InsertChange *
                \ if v:insertmode == 'i' |
                \   silent execute '!echo -ne "\e[6 q"' | redraw! |
                \ elseif v:insertmode == 'r' |
                \   silent execute '!echo -ne "\e[4 q"' | redraw! |
                \ endif
          au VimLeave * silent execute '!echo -ne "\e[ q"' | redraw!
        augroup END
      else
        "Curosr shape in insert mode:
        let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
        let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
      endif

   "}}}

   "tabline {{{1
      nnoremap <leader>gt :let g:gitStatusInTablineShown = !g:gitStatusInTablineShown<cr><C-L>
      if !exists('g:gitStatusInTablineShown')
         let g:gitStatusInTablineShown = 1
      endif
      set showtabline=2 "always show the tabline
      func! GetGitBranch()
         if g:gitStatusInTablineShown
           let cmd = "git status -sb"
         else
           let cmd = "git rev-parse --abbrev-ref HEAD"
         endif
         let branch = substitute(system(cmd), "\n", " |", "g")
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
         let s = " "
         for i in range(tabpagenr('$'))
            " select the highlighting
            let isSelected = i + 1 == tabpagenr()
            if isSelected
               let s .= '%#TabLineSel#'
            else
               let s .= '%#TabLine#'
            endif

            " set the tab page number (for mouse clicks)
            let s .= '%' . (i + 1) . 'T'

            " the label is made by MyTabLabel()
            let label = ' %{MyTabLabel(' . (i + 1) . ')} '

            let s .= label
         endfor
         let s .= '%#TabLineFill# '

         "start on the right
         let s .= '%='
         let s .= '%#TabLineFill# '.'%{GetGitBranch()}'.' '
         return s
      endfunc
      set tabline=%!MyTabLine()
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
      vnoremap il :<C-U>silent! normal 0v$<CR>
      omap il :normal vil<CR>
      vnoremap al :<C-U>silent! normal! 0v$<CR>
      omap al :normal val<CR>
   "entire file (ie/ae) {{{2
      "todo: is there a difference between il and al?
      vnoremap ie :<C-U>silent! normal ggVG<CR>
      omap ie :normal vie<CR>
      vnoremap ae :<C-U>silent! normal ggVG<CR>
      omap ae :normal vae<CR>
   "indent (ii/ai) {{{2
      vnoremap ii :<C-U>silent call <SID>InIndent(0)<CR>
      omap ii :normal vii<CR>
      vnoremap ai :<C-U>silent call <SID>InIndent(1)<CR>
      omap ai :normal vai<CR>
      "vnoremap ai :<C-U>silent! normal 0v$<CR>
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

"nvim {{{1
if has('nvim')
  augroup NVIM
  augroup! NVIM
  "autocmd TermClose * wincmd c
  tnoremap  <c-\><c-n>
  augroup END
endif

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
