-- Small editing helpers shared across ftplugins.
-- Migrated from the duplicated SplitArgs()/JoinVars() vimscript functions
-- that lived in ftplugin/{cpp,go,ts,rust}.vim.

local M = {}

-- Take the call/definition on the current line and spread its arguments one
-- per line. `last_comma` controls whether the final argument gets a trailing
-- comma (go/ts/rust = true, cpp = false).
function M.split_args(last_comma)
  if last_comma == nil then last_comma = true end
  local fn = vim.fn

  local cursor = fn.getpos(".")
  local line = fn.getline(".")
  local indent = string.rep(" ", fn.indent("."))

  local parts = fn.split(line, "(")
  if #parts < 2 then return end
  local before = parts[1]
  line = fn.join(vim.list_slice(parts, 2), "(")

  parts = fn.split(line, ")", 1)
  if #parts < 2 then return end
  local after = parts[#parts]
  line = fn.join(vim.list_slice(parts, 1, #parts - 1), ")")

  local args = fn.split(line, [[,\s*]])
  local out = {}
  for i, a in ipairs(args) do
    if not last_comma and i == #args then
      table.insert(out, indent .. "  " .. a)
    else
      table.insert(out, indent .. "  " .. a .. ",")
    end
  end
  table.insert(out, indent .. ")" .. after)

  fn.append(".", out)
  fn.setline(".", before .. "(")
  fn.setpos(".", cursor)
end

-- Collapse a run of `var x = ...` lines starting at the cursor into a single
-- Go-style `var ( ... )` block.
function M.join_vars()
  local fn = vim.fn
  local startline = fn.line(".")
  local l = startline
  while fn.match(fn.getline(l), [[^\s*var\s\+]]) ~= -1 do
    l = l + 1
  end
  local endline = l - 1
  if endline < startline then return end

  vim.cmd(string.format([[%d,%ds/\s*var\s*/\t/]], startline, endline))
  fn.append(endline, ")")
  fn.append(startline - 1, "var (")
end

return M
