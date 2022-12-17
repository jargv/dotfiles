-- use legacy config (TODO: remove it!) {{{1
vim.cmd [[source ~/config/nvim/legacy_init.vim]]

--create the autogroup that we'll use for everything {{{1
local augroup = "learn.autocmd"
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
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, instructions)

    -- clean up the old buffer, unless it was a named file
    if
      vim.fn.bufname(tonumber(starting_buf)) == "" and
      vim.api.nvim_buf_is_loaded(starting_buf) then
      vim.cmd("silent bwipe! "..starting_buf)
    end
  end
end

-- terminal config {{{1
vim.api.nvim_set_keymap("t", "<A-u>", "<esc>icd ..<cr>", {noremap = true})
vim.api.nvim_set_keymap("t", "<A-r>", "<c-r>", {noremap = true})
vim.api.nvim_create_autocmd({"TermOpen", "BufEnter", "BufLeave"}, {
  group = augroup,
  pattern = "term:/*",
  callback = function(cmd)
    -- no numbers or hidden buffers
    if cmd.event == "TermOpen" then
      vim.wo.number = false
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

-- Navigate between windows, tabs, splits {{{1
vim.api.nvim_set_keymap("n", "<A-h>", "<C-W>h", {noremap = true})
vim.api.nvim_set_keymap("n", "<A-j>", "<C-W>j", {noremap = true})
vim.api.nvim_set_keymap("n", "<A-k>", "<C-W>k", {noremap = true})
vim.api.nvim_set_keymap("n", "<A-l>", "<C-W>l", {noremap = true})

vim.api.nvim_set_keymap("t", "<A-h>", "h", {noremap = true})
vim.api.nvim_set_keymap("t", "<A-j>", "j", {noremap = true})
vim.api.nvim_set_keymap("t", "<A-k>", "k", {noremap = true})
vim.api.nvim_set_keymap("t", "<A-l>", "l", {noremap = true})
vim.api.nvim_set_keymap("t", "<A-y>", "", {noremap = true})

vim.api.nvim_set_keymap("n", "<M-.>", "gt", {noremap = true})
vim.api.nvim_set_keymap("n", "<M-,>", "gT", {noremap = true})
vim.api.nvim_set_keymap("n", "<A-m>", "", {noremap = true, callback = new("tabnew")})
vim.api.nvim_set_keymap("t", "<M-.>", "gt", {noremap = true})
vim.api.nvim_set_keymap("t", "<M-,>", "gT", {noremap = true})
vim.api.nvim_set_keymap("t", "<A-m>", "", {noremap = true, callback = new("tabnew")})

-- create new splits
vim.api.nvim_set_keymap("n", "<M-->", "", {noremap = true, callback = new("new")})
vim.api.nvim_set_keymap("n", "<M-=>", "", {noremap = true, callback = new("vnew")})
vim.api.nvim_set_keymap("n", "<leader>-", "", {noremap = true, callback = new("new")})
vim.api.nvim_set_keymap("n", "<leader>=", "", {noremap = true, callback = new("vnew")})
vim.api.nvim_set_keymap("t", "<M-->", "", {noremap = true, callback = new("new")})
vim.api.nvim_set_keymap("t", "<M-=>", "", {noremap = true, callback = new("vnew")})
vim.api.nvim_set_keymap("n", "<leader>.", "", {noremap = true, callback = new()})

-- git hotkeys {{{1
vim.api.nvim_set_keymap("n", "<leader>gd", ":tabedit term://git difftool -w -- %<cr>>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>gD", ":tabedit term://git difftool -w<cr>>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>gm", ":tabedit term://git difftool -w origin/$(git config j.publish) -- %<cr>>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>gM", ":tabedit term://git difftool -w origin/$(git config j.publish) <cr>>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>gi", ":tabedit term://git rebase -i<cr>>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>gc", ":tabedit term://git done<cr>>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>gg", ":exec ':tabedit term://git '.input('git> ')<cr>>", {noremap = true})

-- fast config {{{1

-- hotkey to open the relevant config files in a tab
vim.api.nvim_set_keymap("n", "<leader>c", "", {
  noremap = true,
  callback = function()
    require('reset_modules')()
    vim.cmd [[
      luafile ~/config/nvim/init.lua
      filetype detect
    ]]
    print "config reloaded"
  end
})

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
vim.api.nvim_set_keymap("n", "<leader>C", "", {
  noremap = true,
  callback = reloadConfig
})

-- reload config if any config scripts change
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  pattern = {"~/config/nvim/**/*.vim", "~/config/nvim/**/*.lua"},
  callback = reloadConfig
})
