
vim.cmd [[source ~/config/nvim/legacy_init.vim]]
local augroup = "learn.autocmd"

-- unmap a bunch of things from the base config
local function unmap(mode, lhs)
  if vim.fn.maparg(lhs, mode) ~= "" then
    vim.api.nvim_del_keymap(mode, lhs)
  end
end
unmap("n", "<leader>tN")
unmap("n", "<leader>to")
unmap("n", "<leader>tc")
unmap("n", "<leader>tn")
unmap("n", "<leader>tk")
unmap("n", "<leader>tj")
unmap("n", "<leader>h")
unmap("n", "<leader>j")
unmap("n", "<leader>k")
unmap("n", "<leader>l")
unmap("n", "<leader>o")
unmap("n", "<leader>i")

--create the autogroup that we'll use for everything
vim.api.nvim_create_augroup(augroup, {
  clear = true --clear everything in it w
})

-- set up a way of creating clean new buffers
local function new(split)
  return function()
    if split ~= nil then
      vim.cmd(split)
    end

    local starting_buf = vim.fn.bufnr("%")
    local buf = vim.api.nvim_create_buf(false, true)
    vim.cmd("b "..buf)
    vim.bo.bufhidden = "wipe"
    vim.api.nvim_buf_set_keymap(buf, "n", ".", ":e term:///bin/zsh<cr>", {})
    vim.api.nvim_buf_set_keymap(buf, "n", "d", ":Explore<cr>", {nowait=true})
    vim.api.nvim_buf_set_keymap(buf, "n", "o", ":FZF --inline-info<cr>", {nowait=true})
    vim.api.nvim_buf_set_keymap(buf, "n", "i", ":Buffers<cr>", {nowait=true})
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q!<cr>", {nowait=true})
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q!<cr>", {nowait=true})

    -- set the contents to the instructions
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, {
      ". -> start a terminal",
      "d -> open a directory",
      "o -> search for a file",
      "i -> search buffers by name",
      "q -> quit",
    })

    -- clean up the old buffer, unless it was a named file
    if
      vim.fn.bufname(tonumber(starting_buf)) == "" and
      vim.api.nvim_buf_is_loaded(starting_buf)
      then
        vim.cmd("silent bwipe! "..starting_buf)
      end

    end
  end

  -- reload this file whenever it is saved
  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = 0,
    group = augroup,
    callback = function()
      vim.cmd("luafile "..vim.fn.expand('%'))
    end
  })

  -- terminal config
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

  -- Navigate between windows, even if they are terminals
  vim.api.nvim_set_keymap("n", "<A-h>", "<C-W>h", {noremap = true})
  vim.api.nvim_set_keymap("n", "<A-j>", "<C-W>j", {noremap = true})
  vim.api.nvim_set_keymap("n", "<A-k>", "<C-W>k", {noremap = true})
  vim.api.nvim_set_keymap("n", "<A-l>", "<C-W>l", {noremap = true})

  vim.api.nvim_set_keymap("t", "<A-h>", "h", {noremap = true})
  vim.api.nvim_set_keymap("t", "<A-j>", "j", {noremap = true})
  vim.api.nvim_set_keymap("t", "<A-k>", "k", {noremap = true})
  vim.api.nvim_set_keymap("t", "<A-l>", "l", {noremap = true})
  vim.api.nvim_set_keymap("t", "<A-y>", "", {noremap = true})

  -- hotkeys within a terminal
  vim.api.nvim_set_keymap("t", "<A-u>", "<esc>icd ..<cr>", {noremap = true})
  vim.api.nvim_set_keymap("t", "<A-r>", "<c-r>", {noremap = true})

  -- navigate tabs, including terminals
  vim.api.nvim_set_keymap("n", "<M-.>", "gt", {noremap = true})
  vim.api.nvim_set_keymap("n", "<M-,>", "gT", {noremap = true})
  vim.api.nvim_set_keymap("n", "<A-m>", "", {noremap = true, callback = new("tabnew")})
  vim.api.nvim_set_keymap("t", "<M-.>", "gt", {noremap = true})
  vim.api.nvim_set_keymap("t", "<M-,>", "gT", {noremap = true})
  vim.api.nvim_set_keymap("t", "<A-m>", "", {noremap = true, callback = new("tabnew")})

  -- git functions
  vim.api.nvim_set_keymap("n", "<leader>gd", ":tabedit term://git difftool -- %<cr>>", {noremap = true})
  vim.api.nvim_set_keymap("n", "<leader>gD", ":tabedit term://git difftool<cr>>", {noremap = true})
  vim.api.nvim_set_keymap("n", "<leader>gh", ":e term://tig<cr>", {noremap = true, nowait = true})

  -- create new splits
  vim.api.nvim_set_keymap("n", "<M-->", "", {noremap = true, callback = new("new")})
  vim.api.nvim_set_keymap("n", "<M-=>", "", {noremap = true, callback = new("vnew")})
  vim.api.nvim_set_keymap("n", "<leader>-", "", {noremap = true, callback = new("new")})
  vim.api.nvim_set_keymap("n", "<leader>=", "", {noremap = true, callback = new("vnew")})
  vim.api.nvim_set_keymap("t", "<M-->", "", {noremap = true, callback = new("new")})
  vim.api.nvim_set_keymap("t", "<M-=>", "", {noremap = true, callback = new("vnew")})
  vim.api.nvim_set_keymap("n", "<leader>.", "", {noremap = true, callback = new()})
