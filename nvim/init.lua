--[[

stuff to look into:
 - treesitter text objects
 - DAP setup, workflow, use
 - move to lazy.nvim for plugins (config next to plugin)

TODO:
  - Make ==== underline not pollute the clipboard (some register?)
  - display git ignore status in status line
]]

-- setup {{{1
vim.g.mapleader = ' '
--vim.opt.shortmess:append({I = true}) -- don't do intro message at startup
local uname = vim.fn.system('uname')
local isLinux = uname == "Linux\n"
local isMac = uname == "Darwin\n"

local mapping = require("mapping")

local leader = mapping.withPrefix("<leader>")
local normal = mapping.inMode("n")
local visual = mapping.inMode("x")
local terminal = mapping.inMode("t")

-- plugins {{{1
-- bootstrap setup {{{2
local plugDir = vim.fn.expand "~/config/nvim/plug"
local function checkPluginSetup()
  local plugUrl = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  local plugFile = plugDir .. "/plug/autoload/plug.vim"

  -- already installed?
  if 1 == vim.fn.isdirectory(plugDir) then
    return false
  end

  print "performing initial plugin setup..."

  -- bootstrap by downloading
  local result = vim.fn.system {
    "curl", "-fLo", plugFile, "--create-dirs", plugUrl
  }
  local error = vim.api.nvim_get_vvar("shell_error")
  if error ~= 0 or #result == 0 then
    print "error downloading plug, no plugins will be installed"
    return false
  end

  return true
end

-- regular setup {{{2
vim.cmd [[filetype off]]
local initial_plugin_setup_is_required = checkPluginSetup()
vim.opt.runtimepath:append(plugDir.."/plug")
vim.call("plug#begin", '~/config/nvim/plug')
local plugin_setup_funcs = {}
local Plug = vim.fn['plug#']

-- Language-specifig plugins {{{2
-- rust {{{3
-- Plug 'rust-lang/rust.vim'
-- Plug 'racer-rust/vim-racer'
vim.g.racer_experimental_completer = 1
vim.g.ycm_rust_src_path = '~/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src'

-- go {{{3
-- Plug 'jargv/vim-go-error-folds'
-- Plug 'fatih/vim-go'
vim.g.go_fmt_command = "goimports"
vim.g.go_fmt_command = "gofmt"
vim.g.go_fmt_fail_silently = 1
vim.g.go_def_mapping_enabled = 0

--don't do whitespace errors, go fmt will eliminate them
vim.g.go_highlight_trailing_whitespace_error = 0
vim.g.go_highlight_array_whitespace_error = 0
vim.g.go_highlight_chan_whitespace_error = 0
vim.g.go_highlight_space_tab_error = 0

--highlight a bunch of stuff
vim.g.go_highlight_operators = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_methods = 1
vim.g.go_highlight_structs = 1
vim.g.go_highlight_interfaces = 1
vim.g.go_highlight_build_constraints = 1
vim.g.go_auto_type_info = 0

--I like my own K key, thanks
vim.g.go_doc_keywordprg_enabled = 0

--I only want my own snippets
vim.g.go_snippet_engine = ""

--I don't want the templates
vim.g.go_template_autocreate = 0

-- "Scope guru to the whole gopath
-- vim.g.go_guru_scope = [""]


-- javascript/typescript {{{3
-- Plug 'ternjs/tern_for_vim'
-- Plug 'jxnblk/vim-mdx-js'
-- Plug 'pangloss/vim-javascript'
-- Plug 'mxw/vim-jsx'
-- Plug 'jelera/vim-javascript-syntax'
-- vim.g.jsx_ext_required = 0
-- Plug 'leafgarland/typescript-vim'
-- Plug 'peitalin/vim-jsx-typescript'
-- Plug 'MaxMellon/vim-jsx-pretty'
-- html {{{3
Plug 'othree/html5.vim'

-- purescript {{{3
-- Plug 'raichoo/purescript-vim'

-- css {{{3
Plug 'JulesWang/css.vim'

-- html {{{3
-- Plug 'mattn/emmet-vim'
-- toml {{{3
Plug 'cespare/vim-toml'
-- docker {{{3
-- Plug 'ekalinin/Dockerfile.vim'


-- lua {{{3
-- Plug 'SpaceVim/vim-swig'

-- zig {{{3
Plug 'ziglang/zig.vim'
vim.g.zig_fmt_autosave = 0

-- java {{{3
Plug 'mfussenegger/nvim-jdtls'

-- colorschemes {{{2
-- Plug 'flazz/vim-colorschemes'
Plug 'arcticicestudio/nord-vim'
Plug 'sainnhe/everforest'
Plug 'trevordmiller/nova-vim'
Plug 'AlessandroYorba/Arcadia'
Plug 'jnurmine/Zenburn'
Plug('sonph/onehalf', { rtp = 'vim' })
Plug 'ntk148v/vim-horizon'
Plug 'navarasu/onedark.nvim'
-- }}}

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
Plug 'hrsh7th/cmp-cmdline'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'
Plug 'hrsh7th/nvim-cmp'
Plug('nvim-treesitter/nvim-treesitter', {['do'] = ':TSUpdate'})

-- Plug 'jose-elias-alvarez/null-ls.nvim' {{{2
Plug 'jose-elias-alvarez/null-ls.nvim'
table.insert(plugin_setup_funcs, function()
  require("null-ls").setup()
end)
-- Plug 'MunifTanjim/eslint.nvim' {{{2
Plug 'MunifTanjim/eslint.nvim'
table.insert(plugin_setup_funcs, function()
  require("eslint").setup({
    bin = 'eslint_d', -- or `eslint_d`
    code_actions = {
      enable = true,
      apply_on_save = {
        enable = true,
        types = { "directive", "problem", "suggestion", "layout" },
      },
      disable_rule_comment = {
        enable = true,
        location = "separate_line", -- or `same_line`
      },
    },
    diagnostics = {
      enable = true,
      report_unused_disable_directives = false,
      run_on = "type", -- or `save`
    },
  })
end)

-- Plug 'nvim-telescope/telescope.nvim' {{{2
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.0' })
Plug('nvim-telescope/telescope-fzf-native.nvim', {['do'] = 'make'})
table.insert(plugin_setup_funcs, function()
  local telescope = require "telescope"
  local action = require "telescope.actions"
  telescope.setup {
    extensions = {
      fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
    },
    defaults = {
      mappings = {
        i = {
          ["<M-a>"] = action.smart_send_to_qflist + action.open_qflist,
          ["<C-f>"] = action.to_fuzzy_refine,
        },
      },
    },
  }
  telescope.load_extension('fzf')
end)

-- Plug 'williamboman/mason.nvim' {{{2
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
table.insert(plugin_setup_funcs, function()
  require"mason".setup()
  require"mason-lspconfig".setup()
end)

-- Plug 'SmiteshP/nvim-navic' {{{2
Plug 'SmiteshP/nvim-navic'
vim.g.winbarShown = 0
leader.v = function()
  vim.g.winbarShown = not vim.g.winbarShown
  if vim.g.winbarShown then
    vim.opt.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
  else
    vim.opt.winbar = ""
  end
end
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

-- Plug 'mazubieta/gitlink-vim' {{{2
Plug 'mazubieta/gitlink-vim'
vim.cmd [[
  function! CopyGitLink(...) range
    redir @+
    echo gitlink#GitLink(get(a:, 1, 0))
    redir END
  endfunction
  nmap <leader>gl :call CopyGitLink()<CR>
  vmap <leader>gl :call CopyGitLink(1)<CR>
]]




-- Plug 'dense-analysis/ale' {{{2
vim.g.ale_fixers = {
  javascript = {'prettier'},
  typescript = {'prettier'},
  javascriptreact = {'prettier'},
  css  = {'prettier'},
  go  = {'goimports'},
  -- c = {'clang-format'},
  -- cpp = {'clang-format'},
}

vim.g.ale_linters_explicit = 1
vim.g.ale_fix_on_save = 1
vim.g.ale_completion_autoimport = 1
Plug 'dense-analysis/ale'

-- Plug 'junegunn/fzf' (unused) {{{2
-- vim.g.fzf_buffers_jump = 1
-- Plug 'junegunn/fzf'
-- Plug 'junegunn/fzf.vim'

-- Plug 'tpope/vim-vinegar' (unused, using oil instead) {{{2
-- Plug 'tpope/vim-vinegar'

-- Plug 'stevearc/oil.nvim' {{{2
Plug 'stevearc/oil.nvim'
table.insert(plugin_setup_funcs, function()
  vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
  require("oil").setup({
    -- Id is automatically added at the beginning, and name at the end
    -- See :help oil-columns
    columns = {
      "icon",
      -- "permissions",
      -- "size",
      -- "mtime",
    },
    -- Buffer-local options to use for oil buffers
    buf_options = {
      buflisted = false,
    },
    -- Window-local options to use for oil buffers
    win_options = {
      -- wrap = false,
      -- signcolumn = "no",
      -- cursorcolumn = false,
      -- foldcolumn = "0",
      -- spell = false,
      -- list = false,
      -- conceallevel = 3,
      -- concealcursor = "n",
    },
    -- Restore window options to previous values when leaving an oil buffer
    restore_win_options = true,
    -- Skip the confirmation popup for simple operations
    skip_confirm_for_simple_edits = false,
    -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
    -- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
    -- Additionally, if it is a string that matches "actions.<name>",
    -- it will use the mapping at require("oil.actions").<name>
    -- Set to `false` to remove a keymap
    -- See :help oil-actions for a list of all available actions
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<C-l>"] = "actions.refresh",
      ["<cr>"] = "actions.select",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["g."] = "actions.toggle_hidden",
    },
    -- Set to false to disable all of the above keymaps
    use_default_keymaps = false,
    view_options = {
      -- Show files and directories that start with "."
      show_hidden = false,
    },
    -- Configuration for the floating window in oil.open_float
    float = {
      -- Padding around the floating window
      padding = 2,
      max_width = 0,
      max_height = 0,
      border = "rounded",
      win_options = {
        winblend = 10,
      },
    },
  })
end)

-- Plug  'SirVer/UltiSnips' {{{2
Plug 'SirVer/UltiSnips'
vim.g.UltiSnipsExpandTrigger=""
vim.g.UltiSnipsJumpForwardTrigger=""
vim.g.UltiSnipsJumpBackwardTrigger=""

vim.g.UltiSnipsEditSplit = 'vertical'
vim.g.UltiSnipsSnippetsDir = '~/config/nvim/my_snippets'

vim.g.UltiSnipsSnippetDirectories = {"my_snippets"}
leader.s = ":UltiSnipsEdit<CR>"

-- Plug 'phaazon/hop.nvim' {{{2
Plug 'phaazon/hop.nvim'
leader.f = ":HopChar1<cr>"
leader.F = ":HopChar1MW<cr>"
table.insert(plugin_setup_funcs, function()
  require('hop').setup()
end)

-- Plug 'lewis6991/gitsigns.nvim' {{{2
Plug 'lewis6991/gitsigns.nvim'
vim.cmd [[
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
]]
table.insert(plugin_setup_funcs, function()
  require('gitsigns').setup()
end)
--}}}

-- finalize plugin setup {{{2
vim.call("plug#end")
-- my config should override EVERYTHING
vim.opt.runtimepath:remove "~/config/nvim" --remove first, added to the end
vim.opt.runtimepath:append "~/config/nvim"

if initial_plugin_setup_is_required then
  vim.cmd [[ PlugInstall! ]]
end

-- run the config funcs
for _,fn in ipairs(plugin_setup_funcs) do
  fn()
end
-- }}}

-- color settings {{{1
vim.opt.termguicolors = true
vim.opt.ttyfast = true

local colorscheme = "onedark"
if colorscheme == "everforest" then
  vim.g.everforest_background = 'soft'
  vim.g.everforest_enable_italic = 1
  vim.g.everforest_cursor = 'orange'
  vim.g.everforest_sign_column_background = 'none'
  vim.g.everforest_dim_inactive_windows = 0
  vim.g.everforest_ui_contrast = 'low'
  vim.g.everforest_show_eob = 1
  vim.g.everforest_diagnostic_text_highlight = 1
  vim.g.everforest_diagnostic_line_highlight = 0
  vim.g.everforest_diagnostic_virtual_text = 'grey' -- 'colored'
  vim.g.everforest_disable_terminal_colors = 0
  vim.cmd.colorscheme("everforest")
  vim.cmd [[ highlight LineNr guibg=#000000 guifg=grey ]]
  vim.o.background = "dark"
  --:NoMatchParen
  vim.g.loaded_matchparen = 1
elseif colorscheme == "onedark" then
  vim.g.onedark_config = {
    style = 'warm',
    term_colors = true,
    code_style = {
      comments = "italic"
    },
    diagnostics = {
      darker = true,
      undercurl = true,
      background = true,
    }
  }
  vim.cmd.colorscheme("onedark")
elseif colorscheme == "horizon" then
  vim.cmd.colorscheme("horizon")
end


-- prototype settings {{{1
visual.v = function()
  vim.cmd.normal("`[o`]")
end
vim.opt.updatetime = 300
local telescope = require("telescope.builtin")
leader.jf = function()
  local dir = require("current_dir")()
  telescope.find_files({cwd = dir})
end
leader.jt = function()
  telescope.treesitter()
end
leader.jm = function()
  telescope.marks()
end
leader.jk = function()
  telescope.keymaps()
end
leader.ja = function()
  telescope.autocommands()
end
leader.jo = function()
  telescope.lsp_outgoing_calls()
end
leader.ji = function()
  telescope.lsp_incoming_calls()
end
leader.jh = function()
  telescope.help_tags()
end
leader.jj = function()
  telescope.resume()
end
leader['j/'] = function()
  local dir = require("current_dir")()
  telescope.live_grep({cwd = dir})
end

leader['/'] = function()
  telescope.lsp_document_symbols({fname_width=70, show_line=true})
end

-- settings {{{1

-- formatting
vim.opt.formatoptions:append('j')

-- indent
vim.opt.cindent = false
vim.opt.smartindent = false
vim.opt.autoindent = true
vim.opt.list = false
vim.opt.listchars = "tab:| "

-- temporary files
vim.opt.backupdir="/tmp"
vim.opt.directory="/tmp"
vim.opt.undodir="/tmp"
vim.opt.backup = false
vim.opt.swapfile = false

-- timeout (snappy)
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 0

-- search
vim.opt.wildmode = "full"
vim.opt.gdefault = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.wrapscan = true
normal["<C-L>"] = ":nohlsearch<cr>:syn sync minlines=99999<cr><C-L>"

-- folds
vim.opt.fillchars:append "fold: " --don't do dashes in the fold lines
vim.cmd [[
set foldtext=MyFoldText()
function! MyFoldText()
  let sub = substitute(foldtext(), '+-*\s*\d*\s*lines:\s*', '', 'g')
  return repeat(' ', &sw * (v:foldlevel - 1)) . sub
endfunction
]]

-- spell check
vim.opt.spelllang="en_us"
vim.opt.spell = false

-- buffers
vim.opt.fillchars:append "eob: " --no "~" at end of buffer
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.cmd [[
  augroup NoSimultaneousEdits
    autocmd!
    autocmd  SwapExists * :let v:swapchoice = 'e'
  augroup END
]]

-- difftool
vim.opt.diffopt={
  "filler", -- show filler lines
  "iwhite"
}

-- whitespace
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftround = true
vim.cmd [[ "blow away triling whitespace
  augroup NukeWhitespace
    autocmd!
    autocmd BufWritePre * :call RemoveTrailingWhitespace()
    func! RemoveTrailingWhitespace()
      let save_cursor = getpos(".")
      %s/\s\+$//e
      call setpos('.', save_cursor)
      nohlsearch
    endfunc
  augroup END
]]

-- indentation/wrapping
vim.opt.joinspaces = false
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:0,sbr"
vim.opt.showbreak = '> '
vim.opt.breakat = " 	!@*-+;:,./?(){}[]"
vim.opt.cpoptions:append"n"

-- tabs
vim.o.showtabline = 1 -- only if there are multiple

-- clipboard
if isLinux then
  vim.opt.clipboard:append("unnamedplus")
elseif isMac then
  vim.opt.clipboard:append("unnamed")
end

--other
vim.g.filetype_pt = "prolog"
vim.opt.scrolloff = 3
vim.opt.fileignorecase = false
vim.opt.virtualedit = "block"
vim.opt.readonly = false
vim.opt.wildmenu = true
vim.opt.wildmode = "full"
vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.backspace = "indent,eol,start"
vim.opt.switchbuf = "useopen,usetab"
vim.opt.undofile = true
vim.opt.hidden = true
vim.opt.history = 10000
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.infercase = true
vim.opt.mouse = "a"
if vim.fn.has("mouse_sgr") ~= 0 then
  vim.opt.ttymouse = "sgr"
end


-- warning on old habit keybinds {{{1
leader.q = function()
  print("nope... bad habit")
end

leader.Q = function()
  print("nope... bad habit")
end

leader.u = function()
  print("nope... use menus")
end

leader.U = function()
  print("nope... use menus")
end

--create the autogroup that we'll use for everything {{{1
local augroup = "j.config.autogroup"
vim.api.nvim_create_augroup(augroup, {
  clear = true --clear everything in it w
})


-- terminal config {{{1
terminal["<A-u>"] = "<esc>icd ..<cr>"
terminal["<C-->"] = "<esc>icd ..<cr>"
terminal["<A-r>"] = "<c-r>"
terminal["<A-p>"] = "p"
terminal["<A-y>"] = ""
vim.api.nvim_create_autocmd({"TermOpen", "BufEnter", "BufLeave"}, {
  group = augroup,
  pattern = "term://*",
  callback = function(cmd)
    -- no numbers or hidden buffers
    if cmd.event == "TermOpen" then
      vim.bo.bufhidden = 'wipe'
      vim.wo.number = false
      vim.wo.spell = false
    end

    -- insert mode shouldn't be affected by terminals
    if cmd.event == "BufLeave" then
      vim.cmd("stopinsert")
    else
      vim.cmd("startinsert")
    end
  end
})

-- navigate between windows, tabs, splits {{{1
local newb = require("newb")

vim.opt.equalalways = true --automatically resize windows

leader.w = "<C-W>"

-- move between windows
normal["<A-h>"] = "<C-W>h"
normal["<A-j>"] = "<C-W>j"
normal["<A-k>"] = "<C-W>k"
normal["<A-l>"] = "<C-W>l"
terminal["<A-h>"] = "h"
terminal["<A-j>"] = "j"
terminal["<A-k>"] = "k"
terminal["<A-l>"] = "l"

-- window resize
leader["<Down>"] = "<C-W>+"
leader["<Up>"] = "<C-W>-"
leader["<Left>"] = "<C-W><"
leader["<Right>"] = "<C-W>>"
normal["<Down>"] = "5<C-W>+"
normal["<Up>"] = "5<C-W>-"
normal["<Left>"] = "5<C-W><"
normal["<Right>"] = "5<C-W>>"

-- rearrange windows
leader.H = "<C-W>H"
leader.J = "<C-W>H"
leader.K = "<C-W>K"
leader.L = "<C-W>L"
leader.tj = ":call MoveWindowTo#NextTab()<cr>"
leader.tk = ":call MoveWindowTo#PrevTab()<cr>"


-- move between tabs
normal["<M-.>"] = "gt"
normal["<M-,>"] = "gT"
terminal["<M-.>"] = "gt"
terminal["<M-,>"] = "gT"

-- create and close tabs
normal["<A-m>"] = newb.create("tabnew")
terminal["<A-m>"] = newb.create("tabnew")
leader.tc = ":tabclose<cr>"
leader.to = ":tabonly<cr>"

-- create new splits
normal["<M-->"] = newb.create("new")
normal["<M-=>"] = newb.create("vnew")
normal["<leader>-"] = newb.create("new")
normal["<leader>="]= newb.create("vnew")
terminal["<M-->"] = newb.create("new")
terminal["<M-=>"] = newb.create("vnew")
leader["."] = function()
  print("remapped to <bs>!")
end
normal["<bs>"] = newb.create()



-- git setup {{{1
local gitato = require "gitato"

local function default_upstream()
  local result = vim.fn.systemlist("git config j.publish")
  if vim.api.nvim_get_vvar("shell_error") ~= 0 or #result == 0 then
    return "origin/main"
  end
  return ("origin/%s"):format(result[1])
end

leader.gg = function() gitato.open_viewer() end
leader.GG = function() gitato.open_viewer(default_upstream()) end

leader.d = function()
  gitato.toggle_diff_against_git_ref("HEAD")
end

leader.D = function()
  gitato.toggle_diff_against_git_ref(vim.fn.input(">", default_upstream()))
end

leader.gb = ":Gitsigns toggle_current_line_blame<cr>"
leader.gB = function()
  package.loaded.gitsigns.blame_line({full=false,ignore_whitespace=true})
end

-- git open buffers
function git_open(diff_branch)
  return function()
    local first = true
    local repo_root = gitato.get_repo_root()
    gitato.status_foreach(diff_branch, function(_status, file)
      if first then
        vim.cmd.tabnew(repo_root .. file)
      else
        vim.cmd.vsplit(repo_root .. file)
      end
      first = false
    end)
  end
end

leader.go = git_open()
leader.Go = git_open(default_upstream())

-- background build setup {{{1
local build = require("background_build")
leader.Me = build.edit_config
leader.e = function()
  vim.fn.setloclist(0, {})
  vim.cmd.lclose()
  build.load_errors()
end
leader.E = build.open_error_output_buffers
leader.m = build.run_all_not_running
leader.Mw = build.open_all_output_buffers
leader.Ma = build.add_from_current_file
leader.Mq = build.clear_config
leader.Mc = build.stop_all

-- statusline setup {{{1
vim.opt.laststatus = 3 -- only one statusline at bottom
vim.opt.showcmd = true
vim.cmd[[
  func! GetRelativeFilename()
    if &buftype == "terminal" || &filetype == "oil"
      let file = luaeval('require"current_dir"()')
      let file = fnamemodify(file, ":p")
    else
      let file = expand("%:p")
    endif

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

  func! GetSymlinkTarget()
    let file = expand("%:p")
    let target = resolve(file)
    if file == target || &buftype == "terminal" || &filetype == "oil"
      return ""
    else
      return "  --> ".fnamemodify(target, ":~")
    endif
  endfunc

  "used for build status
  highlight clear User1
  highlight clear User2
  highlight clear User3
  highlight clear User4
  highlight clear User5
  highlight clear User6
  highlight clear User7
  highlight clear User8
  highlight clear User9

  "used for current dir
  exec "highlight User7 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Keyword'),'fg')
  exec "highlight User8 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Function'),'fg')
  exec "highlight User9 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Boolean'),'fg')

  " not started
  exec "highlight User1 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('StatusLine'),'fg')

  " running
  exec "highlight User2 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Function'),'fg')

  " success
  exec "highlight User3 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('String'),'fg')

  " failed
  exec "highlight User4 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Identifier'),'fg')

  " separator
  exec "highlight User5 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Comment'),'fg')

  " awaiting stream
  exec "highlight User6 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Operator'),'fg')
]]

-- left side
vim.opt.statusline = ""
vim.opt.statusline:append "%y" -- filetype
vim.opt.statusline:append "%7*" -- User6 highlight
vim.opt.statusline:append " %<" -- truncate here, if needed
vim.opt.statusline:append " %{fnamemodify(getcwd(),':~')}/" -- current dir
vim.opt.statusline:append "%8*" -- User7 highlight
vim.opt.statusline:append "%{GetRelativeFilename()}" -- file name relative to cwd
vim.opt.statusline:append "%9*" -- User8 highlight
vim.opt.statusline:append "%{GetSymlinkTarget()}" -- file name relative to cwd
vim.opt.statusline:append "%#StatusLine#" -- regular statusline highlight
vim.opt.statusline:append " %m" -- modified flag -- regular statusline highlight
-- vim.opt.statusline:append ":%l:%c" -- line and column

-- right side
vim.opt.statusline:append "%=" -- separator to indicate right side
vim.opt.statusline:append "%{%v:lua.require'background_build'.statusline()%} " -- file name relative to cwd

-- fast config {{{1

-- hotkey to open the relevant config files in a tab
leader.c = function()
  require('reset_modules')()
  vim.cmd [[
    luafile ~/config/nvim/init.lua
    filetype detect
  ]]
  print "config reloaded"
end

-- reload config
local function reloadConfig()
  local ft_parts = vim.fn.split(vim.bo.filetype, "\\.")
  vim.cmd "tabe ~/config/nvim/init.lua"
  if #ft_parts ~= 0 then
    vim.cmd("vsplit ~/config/nvim/ftplugin/"..ft_parts[1]..".vim")
  end
end

-- invoke a config relaod manually
leader.C = reloadConfig

-- reload config if any config scripts change
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  pattern = {"~/config/nvim/**/*.vim", "~/config/nvim/**/*.lua"},
  callback = reloadConfig
})

-- neovide config {{{1
if vim.g.neovide then
  local scale_delta = 0.05
  vim.g.neovide_hide_mouse_when_typing = isLinux
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_remember_window_size = false
  vim.g.neovide_profiler = false
  vim.g.neovide_input_macos_alt_is_meta = true
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_scroll_animation_length = 0.0
  local font_size = isMac and 14 or 12
  vim.opt.guifont="FiraCode Nerd Font:h"..font_size
  normal["<C-->"] = function()
    local scale_factor = vim.g.neovide_scale_factor or 1.0
    vim.g.neovide_scale_factor = scale_factor - scale_delta
    print("scale at "..vim.g.neovide_scale_factor)
  end
  normal["<C-=>"] = function()
    local scale_factor = vim.g.neovide_scale_factor or 1.0
    vim.g.neovide_scale_factor = scale_factor + scale_delta
    print("scale at "..vim.g.neovide_scale_factor)
  end
  normal["<C-0>"] = function()
    vim.g.neovide_scale_factor = 1.0
    print("scale at "..vim.g.neovide_scale_factor)
  end
end

-- buffer cleanup command {{{1
vim.api.nvim_create_user_command("Bwipe", function()
  local bufs = vim.fn.getbufinfo()
  for _,buf in pairs(bufs) do
    if #buf.windows == 0 then
      vim.api.nvim_buf_delete(buf.bufnr, {force=true})
    end
  end
end, {force = true})

-- text objects {{{1
vim.cmd[[
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
      xnoremap ii :<C-U>silent call TextObjectInIndent(0)<CR>
      omap ii :normal vii<CR>
      xnoremap ai :<C-U>silent call TextObjectInIndent(1)<CR>
      omap ai :normal vai<CR>
      "xnoremap ai :<C-U>silent! normal 0v$<CR>
      "omap ai :normal vai<CR>
      func! TextObjectInIndent(inclusive)
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
]]

-- tabline {{{1
vim.cmd [[
  func! MyTabLabel(n)
    let setName = gettabvar(a:n, "tabname")
    if setName != ""
      return setName
    end
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
]]

-- key mappings {{{1
vim.cmd [[
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
        set number
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
    nnoremap <leader><leader> :wall<cr>:w<cr>

  "K as the opposite of Join {{{2
    xnoremap <silent> K <Nop>
    nnoremap <silent> K :call MyLineFormat() <CR>
    func! MyLineFormat()
        normal Vgq
    endfunc

  "incr/decr then save{{{2
    noremap  :w<CR>
    noremap  :w<CR>

  "get the styles under the cursor {{{2
    map <leader>S :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
  "}}}
]]

-- smart enter {{{2
vim.api.nvim_set_keymap('i', '<cr>', '', {
  expr = true,
  replace_keycodes = true,
  noremap = true,
  nowait = true,
  callback = function()
    local is_lua = vim.bo.filetype == "lua"
    local is_cpp = vim.bo.filetype == "cpp"

    local line = vim.fn.getline('.')
    local p = vim.fn.getpos('.')[3]
    local lastChar = line:sub(p-1,p-1)
    local restOfLine = line:sub(p)
    local firstWord = line:match("%s*(%a*)")
    local lastWord = line:match("(%a*)%s*$")
    local lineIsType = is_cpp and (firstWord == 'struct' or firstWord == 'class')

    if #restOfLine >= 1 then
      local nextToLastChar = restOfLine:sub(1,1)
      local brackets = lastChar == '{' and nextToLastChar == '}'
      local parens   = lastChar == '(' and nextToLastChar == ')'
      local squares  = lastChar == '[' and nextToLastChar == ']'
      if is_cpp and brackets and lineIsType then
        return '<cr><esc>A;<esc>O'
      elseif brackets or parens or squares then
        return '<cr><esc>O'
      end
    elseif is_cpp and lastChar == '{' and lineIsType then
      return '<cr>};<esc>O'
    elseif is_lua and (lastWord == "then" or lastWord == "do") then
      return '<cr><esc>Aend<esc>O'
    end

    return '<cr>'
  end
})

;(function()
  local cmp = require "cmp"
  vim.api.nvim_set_keymap('i', '<tab>', '', {
    callback = function()
      if 1 == vim.fn["UltiSnips#CanExpandSnippet"]() then
        vim.fn["UltiSnips#ExpandSnippet"]()
        return
      end

      if 1 == vim.fn["UltiSnips#CanJumpForwards"]() then
        vim.fn["UltiSnips#JumpForwards"]()
        return
      end

      local column = vim.fn.getpos('.')[3]
      local lineBeforeCursor = vim.fn.getline('.'):sub(0,column-1)
      if lineBeforeCursor:match('%S') then
        cmp.complete()
        return
      end

      local tabkey = vim.api.nvim_replace_termcodes("<tab>", true, false, true)
      vim.api.nvim_feedkeys(tabkey, 'n', false)
    end
  })
end)()

vim.api.nvim_set_keymap('s', '<tab>', '', {
  noremap = true,
  callback = function()
    if 1 == vim.fn["UltiSnips#CanJumpForwards"]() then
      local seq = vim.api.nvim_replace_termcodes("<esc>a<tab>", true, false, true)
      vim.api.nvim_feedkeys(seq, 'm', false)
      return
    end

    local tabkey = vim.api.nvim_replace_termcodes("<tab>", true, false, true)
    vim.api.nvim_feedkeys(tabkey, 'n', false)
  end
})

-- next and previous location/error {{{2
;(function()
  function make_move_fn(qf, ll, close)
    return function()
      local isqf = #vim.fn.getloclist(0) == 0
      local ok = pcall(isqf and qf or ll)
      if not ok then
        if isqf then
          vim.cmd.cclose()
        else
          vim.cmd.lclose()
        end
      end
    end
  end

  leader.n = make_move_fn(vim.cmd.cn, vim.cmd.lnext)
  leader.p = make_move_fn(vim.cmd.cp, vim.cmd.lprev)
  leader.N = make_move_fn(vim.cmd.cnf, vim.cmd.lnf)
  leader.P = make_move_fn(vim.cmd.cpf, vim.cmd.lpf)
end)()
-- }}}

-- zoom {{{1
vim.opt.winminheight = 1
vim.opt.winminwidth = 1
vim.cmd [[
  nnoremap <silent> <M-o> :call ZoomToggle()<CR>
  tnoremap <silent> <M-o> :call ZoomToggle()<CR>
  function! ZoomToggle()
    if exists('t:zoomed') && t:zoomed
      execute t:zoom_winrestcmd
      let t:zoomed = 0
    else
      let t:zoom_winrestcmd = winrestcmd()
      resize
      vertical resize
      let t:zoomed = 1
    endif
  endfunction
]]

-- treesitter {{{1
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
    disable = {"cpp"},

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

-- lsp config {{{1
vim.api.nvim_create_user_command("LspKillAll", function()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
end, {force = true})

normal.gd = function()
  vim.lsp.buf.definition()
  vim.cmd("normal z<cr>")
end

leader.Y = function()
  vim.cmd.wall()
  vim.cmd.ToggleDiagOff()
  vim.cmd.cclose()
end

leader.y = function()
  vim.cmd.cclose()
  vim.cmd.w()
  vim.cmd.ToggleDiagDefault()
  vim.cmd.lclose()
  vim.diagnostic.setloclist({open = false})
  vim.cmd.lwindow()

  if vim.bo.filetype == "qf" then
    vim.cmd[[ exec "normal \<cr>" ]]
  end
end

normal.gD = function() vim.lsp.buf.declaration() end
normal.gi = function() vim.lsp.buf.implementation() end
normal.gu = function() vim.lsp.buf.references() end
normal.gh = function() vim.lsp.buf.hover() end
leader.rn = function() vim.lsp.buf.rename(vim.fn.input('>')) end
leader.rf = function() vim.lsp.buf.code_action{apply = true} end
normal["<cr>"] = function()
  pcall(vim.lsp.buf.code_action, {apply = true})
  pcall(vim.cmd.lnext)
end

if lsp_configured == nil then
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

  lspconfig.tsserver.setup{
    capabilities = capabilities,
    filetypes = {"typescript", "typescriptreact", "typescript.tsx" }
  }

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
    capabilities = capabilities,
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

  lspconfig.bashls.setup {
    capabilities = capabilities,
  }

  lspconfig.bufls.setup{
    capabilities = capabilities,
  }

  lspconfig.flow.setup{
    capabilities = capabilities,
  }

  vim.diagnostic.config({signs = false, virtual_text = false, underline = false})
  require'toggle_lsp_diagnostics'.init({signs = false, virtual_text = true, underline = true})

  lsp_configured = true
end


-- nvim-cmp {{{1
local cmp = require 'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-k>'] = cmp.mapping.scroll_docs(-4),
    ['<C-j>'] = cmp.mapping.scroll_docs(4),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    {
      name = 'nvim_lsp',
      entry_filter = function(entry, ctx)
        return entry:get_kind() ~= cmp.lsp.CompletionItemKind.Text and entry:get_kind() ~= cmp.lsp.CompletionItemKind.Snippet
      end
    },
    { name = 'buffer' },
    { name = 'path' },
  }, {
    { name = 'snippet', max_item_count = 0 },
  })
})

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- error formats {{{1
vim.opt.errorformat = {}

function efmt(str)
  vim.opt.errorformat:append(str)
end

-- typescript
efmt "%f(%l%.%c): error TS%n:%m"

-- c++
-- asserts
efmt "%[%^:]%#: %f:%l: %m"
-- clang and gcc
efmt "%f:%l:%c: error: %m"
-- catch2 errors
efmt "%E%f:%l: FAILED:"
efmt "%C %#%m"
efmt "%Z#"

-- golang
efmt "%f:%l:%c: %#%m"

-- lua
efmt "/usr/bin/lua: %f:%l: %m"
efmt "%f:%l:%m"


-- starting buffer {{{1
if vim.api.nvim_buf_get_name(0) == "" then
  vim.cmd.cd('~/projects')
  -- newb.create()()
  vim.cmd.e("term://~/projects///bin/zsh")
end

-- shell hooks {{{1
require "shell_hooks"

-- tab names {{{1
normal["<A-n>"] = function()
  vim.t.tabname = vim.fn.input(">", vim.t.tabname or "")
  vim.o.tabline = vim.o.tabline -- force a redraw to pick up the name
end

-- statusline update {{{1
if statusline_timer ~= nil then
  statusline_timer:stop()
end

statusline_timer = vim.loop.new_timer();
statusline_setting = vim.opt.statusline
statusline_timer:start(100, 100, function()
  -- schedule a function to be run on the main thread
  vim.defer_fn(function()
    -- setting the option forces an update
    vim.opt.statusline = statusline_setting
  end, 0)
end)
