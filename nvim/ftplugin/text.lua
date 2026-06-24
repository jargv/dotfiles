local mapping = require("mapping")
local normal = mapping.buffer("n")
local allmodes = mapping.buffer("")
local insertGlobal = mapping.inMode("i")

-- distraction-free writing {{{1
vim.b.writing = 0

local writing_on, writing_off

writing_on = function()
  vim.b.writing = 1
  local width = 55
  vim.opt_local.textwidth = width
  vim.cmd("PencilHard")
  vim.cmd("Limelight")
  vim.cmd("Goyo " .. (width + 2))

  vim.b.colorscheme = vim.g.colors_name
  vim.cmd("colorscheme asmdev")
  vim.cmd("hi EndOfBuffer ctermfg=white guifg=bg")

  local grp = vim.api.nvim_create_augroup("Writing", { clear = true })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = grp,
    buffer = 0,
    callback = function() writing_off() end,
  })
end

writing_off = function()
  vim.b.writing = 0
  vim.cmd("PencilOff")
  vim.cmd("Limelight!")
  vim.cmd("Goyo!")
  vim.cmd("colorscheme " .. (vim.b.colorscheme or vim.g.colors_name))
  vim.cmd("hi EndOfBuffer ctermfg=bg guifg=bg")
  vim.api.nvim_create_augroup("Writing", { clear = true })
end

local function toggle_writing()
  if vim.b.writing == 1 then
    writing_off()
  else
    writing_on()
  end
end

allmodes["<leader>;;"] = toggle_writing

-- underline with ==== {{{1
insertGlobal["<C-o>"] = '<esc>"yyy"ypVr=o'

-- gather todos {{{1
normal["<leader>;g"] = [[:s/^[\ -]*/### /<cr>:nohlsearch<cr>]]
normal["<leader>;G"] = [[:let g:reg=@x<cr>:let @x=''<cr>:%g/^###/d X<cr>gg"xP:let @x = g:reg<cr>]]

-- outline folding {{{1
vim.opt.debug = "msg"
vim.opt.foldmethod = "marker"

normal["<leader>;f"] = [[:set foldmethod=expr<cr>:echo "folding in outline mode"<cr>]]
vim.opt_local.foldexpr = "v:lua.TextOutlineFold(v:lnum)"

function _G.TextOutlineFold(lnum)
  local line = vim.fn.getline(lnum)
  local firstNonSpace = vim.fn.match(line, [[\S]])

  local nextLine = vim.fn.getline(lnum + 1)
  local nextLineFirstNonSpace = vim.fn.match(nextLine, [[\S]])

  if firstNonSpace == -1 or nextLineFirstNonSpace <= firstNonSpace then
    return "="
  end

  local indent = math.floor(firstNonSpace / 2) + 1

  local ch = line:sub(firstNonSpace + 1, firstNonSpace + 1)
  if ch == "-" or ch == "+" then
    return ">" .. indent
  end

  return "="
end
