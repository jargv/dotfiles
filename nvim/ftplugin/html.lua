-- HTML ftplugin (migrated from html.vim)

local fn = vim.fn

-- tag wrapping {{{1
-- Runs through a :<C-u> mapping so visual mode is left and the `< / `> marks
-- are set before the function runs (mirrors the original `vnoremap :call`).
local function wrap_tag()
  local tagName = fn.input("Tag name:")
  local pos = fn.getpos(".")
  local keys
  if fn.line("'<") == fn.line("'>") then
    keys = "`>a</" .. tagName .. ">\27`<i<" .. tagName .. ">"
  else
    keys = "`>o</" .. tagName .. ">\27>>`<O<" .. tagName .. ">\27gv>"
  end
  vim.api.nvim_feedkeys(keys, "nx", false)
  fn.setpos(".", pos)
end
_G.__html_wrap_tag = wrap_tag
vim.keymap.set("x", "<Leader>;w", ":<C-u>lua _G.__html_wrap_tag()<CR>", { buffer = true })

-- change element name {{{1
local function change_tag()
  local new = fn.input("new tag name:")
  -- \27 = <Esc>, \15 = <C-o> (jump back); literal `^l` reposition between tags
  return "f>h%lciw" .. new .. "\27\15^lciw" .. new .. "\27"
end
vim.keymap.set("n", "<Leader>;t", change_tag, { buffer = true, expr = true, remap = true })

-- dont do the underlines and bolds for links and strongs, etc. in html {{{1
vim.g.html_no_rendering = 1

-- <leader>;k reformats long attributes {{{1
local function split_attrs()
  local def = vim.o.gdefault
  vim.o.gdefault = false

  local startline = fn.line(".")
  vim.cmd([[s/\v([-A-Za-z0-9_]+\="[^"]*")/&/ge]])
  vim.cmd([[s/><\//><\//e]])
  if fn.match(fn.getline("."), [[\s*<]]) == -1 then
    vim.cmd([[s/\/\?>\s*$/&/e]])
  end
  vim.cmd("normal =" .. startline .. "gg")

  vim.o.gdefault = def
end
vim.keymap.set("", "<leader>;k", split_attrs, { buffer = true, remap = true })

-- alignment and closing errors {{{1
local function find_alignment_errors()
  local startingPoint = fn.getcurpos()
  vim.cmd("normal ggVG=")
  local lnum = 0
  local stack = {}
  while lnum <= fn.line("$") do
    local text = fn.getline(lnum)
    if fn.match(text, [[^\s*<\!]]) ~= -1 then
      -- do nothing with comments
    elseif fn.match(text, [[^\s*<\/]]) ~= -1 then
      local items = fn.matchlist(text, [[\v^(\s*)\<\/([^\ >]*)]])
      if #items >= 3 and #stack > 0 then
        local endIndent = #items[2]
        local endTag = items[3]
        local top = stack[#stack]
        local startLine, startIndent, startTag = top[1], top[2], top[3]
        if endIndent ~= startIndent or startTag ~= endTag then
          fn.cursor(startLine, startIndent)
          vim.cmd("normal zz")
          return
        end
        table.remove(stack)
      end
    elseif fn.match(text, [[^\s*\/>]]) ~= -1 then
      table.remove(stack)
    elseif fn.match(text, [[^\s*<]]) ~= -1 then
      local items = fn.matchlist(text, [[^\(\s*\)<\([^\ >]*\)]])
      if #items >= 3 then
        local indent = #items[2]
        local tag = items[3]
        local isClosed = fn.match(text, [[<\/]] .. tag) ~= -1 or fn.match(text, [[\/>\s*$]]) ~= -1
        if not isClosed then
          table.insert(stack, { lnum, indent, tag })
        end
      end
    end
    lnum = lnum + 1
  end

  if #stack > 0 then
    local first = stack[1]
    fn.cursor(first[1], first[2])
  else
    fn.setpos(".", startingPoint)
    vim.cmd("normal zz")
  end
end
vim.keymap.set("", "<leader>;a", find_alignment_errors, { buffer = true, remap = true })
