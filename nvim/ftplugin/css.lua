-- Options {{{1
vim.opt.iskeyword:append("-,@-@")

-- mappings {{{1
vim.keymap.set("", "<F3>", ':exec "e ".expand("%:r").".js"<cr>', { buffer = true, remap = true })

local function shift_tab()
  if vim.fn.pumvisible() ~= 0 then
    return ""
  else
    return "<S-Tab>"
  end
end
vim.keymap.set("i", "<S-TAB>", shift_tab, { buffer = true, expr = true })

-- near-noop kept from the original (literal @ -> @)
vim.keymap.set("i", "@", "@", { buffer = true })

local function semicolon()
  if vim.fn.match(vim.fn.getline("."), ":") ~= -1 then
    return ";"
  else
    return ": "
  end
end
vim.keymap.set("i", ";", semicolon, { buffer = true, expr = true })

local function space()
  return " "
end
vim.keymap.set("i", "<Space>", space, { buffer = true, expr = true })

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
vim.keymap.set("n", "<F4>", outline_css, { buffer = true })
