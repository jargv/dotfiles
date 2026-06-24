-- Options {{{1
vim.opt.iskeyword:append("-,@-@")

local mapping = require("mapping")
local normal = mapping.buffer("n")
local insert = mapping.buffer("i")
local allmodes = mapping.buffer("")

-- mappings {{{1
allmodes["<F3>"] = { ':exec "e ".expand("%:r").".js"<cr>', remap = true }

local function shift_tab()
  if vim.fn.pumvisible() ~= 0 then
    return ""
  else
    return "<S-Tab>"
  end
end
insert["<S-TAB>"] = { shift_tab, expr = true }

-- near-noop kept from the original (literal @ -> @)
insert["@"] = "@"

local function semicolon()
  if vim.fn.match(vim.fn.getline("."), ":") ~= -1 then
    return ";"
  else
    return ": "
  end
end
insert[";"] = { semicolon, expr = true }

local function space()
  return " "
end
insert["<Space>"] = { space, expr = true }

-- change from inline {{{1
local function outline_css()
  vim.cmd([==[
    "replace foo:{ with .foo{
    s/^\v(\w*)\s*\:\s*\{/.\1 {/e

    "remove single qutoes from the value
    s/\v^(\s*\w*)\:\s*'([^']*)'(.*)/\1:\ \2\3/e

    "remove double qutoes from the value
    s/\v^(\s*\w*)\:\s*"([^"]*)"(.*)/\1:\ \2\3/e

    "remove backtick qutoes from the value
    s/\v^(\s*\w*)\:\s*`([^`]*)`(.*)/\1:\ \2\3/e

    "change `+ "px"` to just px
    s/\v\s*\+\s*["']px["'](.*)$/px\1/e

    "remove the trailing comma at the end of a block
    s/},/}/e

    "replace trailing comma at the end of a value
    s/,\s*$/;/e

    "camelCase to snake-case properties
    s/\v^(\s*)(\l*)(\u)(\l*):/\1\2-\l\3\4:/e
  ]==])
end
normal["<F4>"] = outline_css
