-- use legacy config (TODO: remove it!) {{{1
vim.cmd [[source ~/config/nvim/legacy_init.vim]]

-- set up key mapping objects  {{{1
local mapping = require("mapping")
local leader = mapping.withPrefix("<leader>")
local normal = mapping()
local terminal = mapping.inMode("t")

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

-- function new for clean new buffers with menu {{{1
local new_buffer_options = {
  {key=".", cmd=":e term:///bin/zsh<cr>",     desc="start a terminal"},
  {key="d", cmd=":Explore<cr>",               desc="open a directory"},
  {key="o", cmd=":FZF --inline-info<cr>",     desc="search for a file"},
  {key="i", cmd=":Buffers<cr>",               desc="search buffers by name"},
  {key="h", cmd=":e term://tig<cr>",          desc="git history (tig)"},
  {key="s", cmd=":e term://tig status<cr>",   desc="git status (tig)"},
  {key="g", cmd=":e term://git difftool<cr>", desc="git diff tool"},
  {key="q", cmd=":q!<cr>",                    desc="quit"},
}

local function new(split)
  return function()
    if split ~= nil then
      vim.cmd(split)
    end

    local starting_buf = vim.fn.bufnr("%")
    local buf = vim.api.nvim_create_buf(false, true)
    vim.cmd("b "..buf)
    vim.bo.bufhidden = "wipe"

    -- set up the key bindings and collect the instructions
    local instructions = {}
    for i,val in ipairs(new_buffer_options) do
      vim.api.nvim_buf_set_keymap(buf, "n", val.key, val.cmd, {nowait=true})
      table.insert(instructions, val.key.." -> "..val.desc)
    end

    -- set the contents to the instructions
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, instructions)

    -- clean up the old buffer, unless it was a named file
    if
      vim.fn.bufname(tonumber(starting_buf)) == "" and
      vim.api.nvim_buf_is_loaded(starting_buf) then
      vim.cmd("silent bwipe! "..starting_buf)
    end
  end
end

-- terminal config {{{1
terminal["<A-u>"] = "<esc>icd ..<cr>"
terminal["<A-r>"] = "<c-r>"
vim.api.nvim_create_autocmd({"TermOpen", "BufEnter", "BufLeave"}, {
  group = augroup,
  pattern = "term:/*",
  callback = function(cmd)
    -- no numbers or hidden buffers
    if cmd.event == "TermOpen" then
      vim.bo.bufhidden = 'wipe'
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
normal["<A-h>"] = "<C-W>h"
normal["<A-j>"] = "<C-W>j"
normal["<A-k>"] = "<C-W>k"
normal["<A-l>"] = "<C-W>l"

terminal["<A-h>"] = "h"
terminal["<A-j>"] = "j"
terminal["<A-k>"] = "k"
terminal["<A-l>"] = "l"
terminal["<A-y>"] = ""

normal["<M-.>"] = "gt"
normal["<M-,>"] = "gT"
normal["<A-m>"] = new("tabnew")
terminal["<M-.>"] = "gt"
terminal["<M-,>"] = "gT"
terminal["<A-m>"] = new("tabnew")

-- create new splits
normal["<M-->"] = new("new")
normal["<M-=>"] = new("vnew")
normal["<leader>-"] = new("new")
normal["<leader>="]= new("vnew")

terminal["<M-->"] = new("new")
terminal["<M-=>"] = new("vnew")
normal["<leader>."] = new()

-- git setup {{{1
-- leader.gd = ":tabedit term://git difftool -w -- %<cr>"
-- leader.gD = ":tabedit term://git difftool -w<cr>"
local gitato = require"gitato"
leader.gm = ":tabedit term://git difftool -w origin/$(git config j.publish) -- %<cr>"
leader.gM = ":tabedit term://git difftool -w origin/$(git config j.publish) <cr>"
leader.gi = ":tabedit term://git rebase -i<cr>"
leader.gc = ":tabedit term://git done<cr>"
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
  vim.opt.guifont="FiraCode Nerd Font:h12"
  normal["<C-->"] = function()
    local scale_factor = vim.g.neovide_scale_factor or 1.0
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - scale_delta
    print("scale at "..vim.g.neovide_scale_factor)
  end
  normal["<C-=>"] = function()
    local scale_factor = vim.g.neovide_scale_factor or 1.0
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + scale_delta
    print("scale at "..vim.g.neovide_scale_factor)
  end
  normal["<C-0>"] = function()
    vim.g.neovide_scale_factor = 1.0
    print("scale at "..vim.g.neovide_scale_factor)
  end
end
