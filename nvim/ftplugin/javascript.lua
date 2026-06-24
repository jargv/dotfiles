local mapping = require("mapping")
local normal = mapping.buffer("n")
local insert = mapping.buffer("i")
local visual = mapping.buffer("x")

insert["."] = "."

-- formatting / linting {{{1
vim.opt_local.indentexpr = ""
vim.opt_local.smartindent = false
vim.opt_local.cindent = false
vim.opt_local.autoindent = false
vim.opt_local.formatprg = "standard --stdin --fix"
vim.opt_local.indentkeys = "o,O,*<Return>,<CR>,{,}"

-- <Leader>;t: change a function's declaration style {{{1
local function flip_header_type()
  local line = vim.fn.getline(".")
  if vim.fn.match(line, [[\<var\>]]) ~= -1 then
    vim.cmd([[s/^\(\s*\)var\s\+\(\w*\)\s*=\s*function(\([^)]*\))\s*{\s*$/\1function\ \2(\3){/e]])
  elseif vim.fn.match(line, [[^\s*function]]) ~= -1 then
    local pattern = [[\s*function\s*\([A-Z]\w*\)]]
    local savedscs = vim.o.smartcase
    vim.o.smartcase = true
    local ctorLine = vim.fn.search(pattern, "bWn")
    vim.o.smartcase = savedscs
    local ctorName = vim.fn.get(vim.fn.matchlist(vim.fn.getline(ctorLine), pattern), 1, "")
    if ctorName ~= "" then
      vim.cmd([[s/^\(\s*\)function\s\+\(\w*\)(\([^)]*\))\s*{\s*$/\1]] .. ctorName .. [[\.prototype\.\2\ =\ function(\3){/e]])
    else
      vim.cmd([[s/^\(\s*\)function\s\+\(\w*\)(\([^)]*\))\s*{\s*$/\1var\ \2\ =\ function(\3){/e]])
    end
  elseif vim.fn.match(line, [[\.prototype\.]]) ~= -1 then
    vim.cmd([[s/^\(\s*\)\w*\.prototype./\1var\ /e]])
  end
  vim.cmd("echo")
end
normal["<Leader>;t"] = flip_header_type

-- <Leader>;w: wrap a block in { {{{1
visual["<Leader>;w"] = ">'>o}'<O {hi"

-- <Leader>;u: unwrap a block {{{1
normal["<Leader>;u"] = "m'vi{<'>jdd'<kdd`'k"

-- <Leader>;e: extract variable {{{1
local function extract_variable()
  local name = vim.fn.input("name: ")
  return "c" .. name .. "<Esc>Ovar " .. name .. " = <Esc>p`]a;<Esc>"
end
visual["<Leader>;e"] = { extract_variable, expr = true }
