--[[ stuff to look into:
 - null-ls
 - treesitter text objects
 - telescope to replace fzf
]]
-- setup {{{1
vim.g.mapleader = ' '
--vim.opt.shortmess:append({I = true}) -- don't do intro message at startup
-- local isLinux = vim.fn.system('uname') == "Linux\n"

-- use legacy config (TODO: remove it!) {{{1
vim.cmd [[source ~/config/nvim/legacy_init.vim]]
-- set up key mapping objects  {{{1
local mapping = require("mapping")

local leader = mapping.withPrefix("<leader>")
local normal = mapping()
local visual = mapping.inMode("v")
local terminal = mapping.inMode("t")

-- prototype settings {{{1
visual.v = "`[o`]"
vim.opt.updatetime = 300
vim.opt.laststatus = 3 -- only one statusline at bottom

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
vim.opt.clipboard:append("unnamedplus")

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
vim.opt.completeopt = "menuone,noinsert"
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

--create the autogroup that we'll use for everything {{{1
local augroup = "j.config.autogroup"
vim.api.nvim_create_augroup(augroup, {
  clear = true --clear everything in it w
})


-- terminal config {{{1
terminal["<A-u>"] = "<esc>icd ..<cr>"
terminal["<A-r>"] = "<c-r>"
terminal["<A-p>"] = "pa"
terminal["<A-y>"] = ""
vim.api.nvim_create_autocmd({"TermOpen", "BufEnter", "BufLeave"}, {
  group = augroup,
  pattern = "term://*",
  callback = function(cmd)
    -- no numbers or hidden buffers
    if cmd.event == "TermOpen" then
      vim.bo.bufhidden = 'wipe'
      vim.wo.number = false
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
normal["<A-h>"] = "<C-W>h"
normal["<A-j>"] = "<C-W>j"
normal["<A-k>"] = "<C-W>k"
normal["<A-l>"] = "<C-W>l"

terminal["<A-h>"] = "h"
terminal["<A-j>"] = "j"
terminal["<A-k>"] = "k"
terminal["<A-l>"] = "l"

normal["<M-.>"] = "gt"
normal["<M-,>"] = "gT"
normal["<A-m>"] = newb.create("tabnew")
terminal["<M-.>"] = "gt"
terminal["<M-,>"] = "gT"
terminal["<A-m>"] = newb.create("tabnew")

-- create new splits
normal["<M-->"] = newb.create("new")
normal["<M-=>"] = newb.create("vnew")
normal["<leader>-"] = newb.create("new")
normal["<leader>="]= newb.create("vnew")

terminal["<M-->"] = newb.create("new")
terminal["<M-=>"] = newb.create("vnew")
normal["<leader>."] = newb.create()

-- git setup {{{1
-- leader.gd = ":tabedit term://git difftool -w -- %<cr>"
-- leader.gD = ":tabedit term://git difftool -w<cr>"
local gitato = require "gitato"
-- leader.gm = ":tabedit term://git difftool -w origin/$(git config j.publish) -- %<cr>"
-- leader.gM = ":tabedit term://git difftool -w origin/$(git config j.publish) <cr>"
-- leader.gi = ":tabedit term://git rebase -i<cr>"
-- leader.gc = ":tabedit term://git done<cr>"
-- leader.gg = ":exec ':tabedit term://git '.input('git> ')<cr>"
leader.gg = function() gitato.open_viewer() end

leader.d = function()
  gitato.toggle_diff_against_git_ref("HEAD")
end

leader.D = function()
  print("TODO: make this reference the publish branch!")
  do return end
  gitato.toggle_diff_against_git_ref("main")
end

-- background build setup {{{1
local build = require("background_build")
leader.Me = build.edit_config
leader.e = build.load_errors
leader.E = build.view_output
leader.m = build.run_all_not_running
leader.Ma = build.add_from_current_file
leader.Mq = build.clear_config
leader.Mc = build.stop_all

-- statusline setup {{{1
vim.opt.showcmd = true
vim.cmd[[
  func! GetRelativeFilename()
    let file = expand("%:p")
    let parts = split(file, ':')
    if len(parts) == 3
      return "[".parts[2]."]"
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

  "used for build status
  highlight clear User1
  highlight clear User2
  highlight clear User3
  highlight clear User4

  "used for current dir
  highlight clear User6
  highlight clear User7
  exec "highlight User6 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Keyword'),'fg')
  exec "highlight User7 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Function'),'fg')

  " not started
  exec "highlight User1 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('StatusLine'),'fg')

  " running
  exec "highlight User2 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Blue'),'fg')

  " success
  exec "highlight User3 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Green'),'fg')

  " failed
  exec "highlight User4 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Red'),'fg')

  " separator
  exec "highlight User5 gui=NONE guibg=".synIDattr(hlID('StatusLine'),'bg')." guifg=".synIDattr(hlID('Comment'),'fg')
]]

-- left side
vim.opt.statusline = ""
vim.opt.statusline:append "%y" -- filetype
vim.opt.statusline:append "%6*" -- User5 highlight
vim.opt.statusline:append " %<" -- truncate here, if needed
vim.opt.statusline:append " %{fnamemodify(getcwd(),':~')}/" -- current dir
vim.opt.statusline:append "%7*" -- User6 highlight
vim.opt.statusline:append "%{GetRelativeFilename()}" -- file name relative to cwd
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
  vim.cmd "tabe ~/config/nvim/legacy_init.vim"
  vim.cmd "vsplit ~/config/nvim/init.lua"
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
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_profiler = false
  vim.g.neovide_input_macos_alt_is_meta = false
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_scroll_animation_length = 0.0
  vim.opt.guifont="FiraCode Nerd Font:h12"
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
