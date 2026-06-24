local eh = require("edit_helpers")

-- better c++11 syntax support {{{1
vim.g.c_no_curly_error = 1
vim.g.c_no_bracket_error = 1

-- swap header and source {{{1
vim.keymap.set("n", "<leader>;h", ":e %:p:s,.hpp$,.X123X,:s,.cpp$,.hpp,:s,.X123X$,.cpp,<CR>", { buffer = true })

-- general settings {{{1
vim.opt.wildignore = "*.o"
vim.opt.spell = false

-- <leader>;t: move out of header {{{1
local function move_out_of_header()
  local fn = vim.fn
  local pattern = [[^\s*\(class\|struct\)\s*\([A-Za-z_][A-Za-z0-9_]*\)]]
  local pos = fn.getpos(".")
  local col = pos[3]
  local lineNumber = pos[2]
  local line = fn.getline(".")

  -- get the class name
  local classStartLine = fn.searchpair([[struct\|class]], "", [[};]], "bWn")
  local className = fn.matchlist(fn.getline(classStartLine), pattern)[3] or ""

  -- figure out what the new definition
  local definitionHeader
  if fn.match(line, [[^\s*friend]]) ~= -1 then
    definitionHeader = fn.substitute(line, [[friend\s*]], [[\1]], "")
  else
    definitionHeader = line:sub(1, col - 1) .. className .. "::" .. line:sub(col)
  end

  -- figure out the new declaration
  fn.search("(")
  local endCol = fn.searchpairpos("(", "", ")", "Wn")[2]

  local continueFindingCV = true
  while continueFindingCV do
    continueFindingCV = false
    for _, cv in ipairs({ "&&", "const", "volatile", "noexcept", "final", "override" }) do
      local constStart = fn.match(fn.getline("."):sub(endCol + 1), cv)
      if constStart ~= -1 then
        endCol = endCol + constStart + #cv
        continueFindingCV = true
      end
    end
  end
  local declaration = line:sub(1, endCol) .. ";"

  -- find the body of the definition
  fn.setpos(".", pos)
  fn.search("{")
  local endline = fn.searchpair("{", "", "}", "Wn")

  -- pull out the definition and unindent it
  local definition = fn.getline(lineNumber + 1, endline)
  table.insert(definition, 1, definitionHeader)
  local spaces = fn.match(definition[1], [[\S]])
  for i, v in ipairs(definition) do
    definition[i] = v:sub(spaces + 1)
  end
  vim.cmd(string.format("%d,%dd _", lineNumber, endline))

  -- put the declaration in
  fn.append(lineNumber - 1, declaration)

  -- add the definition to the cpp file
  vim.cmd([[w | e %:p:s,.hpp$,.X123X,:s,.cpp$,.hpp,:s,.X123X$,.cpp,]])
  fn.append(fn.line("$"), "")
  fn.append(fn.line("$"), definition)
  vim.cmd([[w | e %:p:s,.hpp$,.X123X,:s,.cpp$,.hpp,:s,.X123X$,.cpp,]])

  -- restore the original position
  fn.setpos(".", pos)
end
vim.keymap.set("n", "<leader>;t", move_out_of_header, { buffer = true })

-- remove std:: {{{1
vim.keymap.set("n", "<leader>;s", ":%s/std:://<cr>", { buffer = true })

-- wrap block in lambda {{{1
vim.keymap.set("n", "<leader>;b", ":normal i[]()l%a();", { buffer = true })

-- folding {{{1
vim.opt_local.foldnestmax = 20
vim.keymap.set("n", "<leader>;f", ":set foldmethod=syntax<cr>", { buffer = true })

-- convert lua to C++ {{{1
local function transpile(l1, l2)
  local pos = vim.fn.getpos(".")
  for lnum = l1, l2 do
    vim.fn.cursor(lnum, 1)
    vim.cmd([==[
      s/local/auto/e
      s/elseif/} else if /e
      s/if\s*\(.*\)\s*then/if (\1){/e
      s/while\s*\(.*\)\s*then/while (\1){/e
      s/end/}/e
      s/function\s*(\(.*\))/[\&](\1){/e
      s/function\s*\([a-zA-Z0-9]*\)(\(.*\))/auto \1 = [\&](\2){/e
      s/function\s*\([^:\.]*\)\.method:\([^:]*\)(\(.*\))/auto \1::\2(\3){/e
      s/function\s*\([^:]*\):new(\(.*\))/\1::\1(\2){/e
      s/function\s*\([^:]*\):\([^:]*\)(\(.*\))/auto \1::\2(\3){/e
      s/for\s*_,\([^ ]*\)\s\+in\s\+ipairs(\(.*\))/for (auto\& \1 : \2)/e
      s/for\s\+\([^ ]*\)\s\+=\s\+\([^,]*\),\([^ ]*\)/for(auto \1 = \2; \1 < \3; ++\1)/e
      s/for\s\+\([^ ,]*\)\s*,\s*\([^ ]*\)\s\+in\s\+pairs(\([^)]*\))\s*do/for(auto\& pair : \3){auto\& \1 = pair.firstauto\& \2 = pair.second/e
      s/for\s\+\([^ ,]*\)\s*,\s*\([^ ]*\)\s\+in\s\+ipairs(\([^)]*\))\s*do/for(size_t _i = 0; _i < \3.size(); ++_i){auto \1 = _i+1auto\& \2 = \3[i]/e
      s/#\(\w*\)/\1.size()/e
      s/table\.insert(\([^,]*\),\s*\([^(]*\%(([^)]*)[^(]*\)*\))/\1.push_back(\2);/e
      s/\([A-Za-z0-9_]\+\):\([A-Za-z0-9_]\+\)/\1\.\2/e
      s/\~=/\!=/e
      s/self:/this->/e
      s/self\./this->/e
      s/\s*do\s*$/{/e
      s/--\[\[/\/\*/e
      s/--\]\]/\*\//e
      s/--/\/\//e
      s/\.\./+/e
      s/\<and\>/\&\&/e
      s/\<or\>/||/e
      s/\<nil\>/nullptr/e
    ]==])
  end
  vim.fn.setpos(".", pos)
end
vim.keymap.set("n", "<leader>;L", function() transpile(vim.fn.line("."), vim.fn.line(".")) end, { buffer = true })
vim.keymap.set("x", "<leader>;l", function()
  local l1, l2 = vim.fn.line("v"), vim.fn.line(".")
  if l1 > l2 then l1, l2 = l2, l1 end
  transpile(l1, l2)
end, { buffer = true })
vim.keymap.set("n", "<leader>;l", function() transpile(1, vim.fn.line("$")) end, { buffer = true })

-- <leader>;k = SplitArgs() (cpp variant: no trailing comma on last arg) {{{1
vim.keymap.set("n", "<leader>;k", function() eh.split_args(false) end, { buffer = true })

-- original used the invalid `noreab <local> assert check` (<local> isn't real
-- abbrev syntax -- almost certainly meant <buffer>)
vim.cmd("inoreabbrev <buffer> assert check")
