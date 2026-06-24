vim.opt_local.foldmethod = "marker"

-- `op=` shortcuts {{{1
-- Typing `x +=` expands to `x = x +` (etc.), since Lua has no compound-assign.
-- NOTE: the original abbreviations (`inoreab <buffer> += =<SID>opEquals('+')<cr>`)
-- were missing `<expr>`, so they inserted literal garbage instead of expanding --
-- effectively non-functional. Restored here as proper <expr> abbreviations.
function _G.LuaOpEquals(op)
  local line = vim.fn.getline(".")
  local list = vim.fn.matchlist(line, [[^\s*\([a-zA-Z0-9_\.]\+\)]])
  if #list < 2 then
    return op .. "="
  end
  local result = list[2]
  return "= " .. result .. " " .. op
end

for lhs, op in pairs({ ["+="] = "+", ["-="] = "-", ["/="] = "/", ["*="] = "*", ["or="] = "or", ["and="] = "and" }) do
  vim.cmd(string.format([[inoreabbrev <buffer> <expr> %s v:lua.LuaOpEquals('%s')]], lhs, op))
end

-- misc {{{1
vim.keymap.set("i", "@@", "---@") -- global in the original (no <buffer>)

vim.cmd([[inoreabbrev <buffer> != ~=]])

-- <leader>;a : turn `assert(cond)` into an `if not cond then error(...) end` {{{1
local function trim(code)
  local parts = vim.fn.matchlist(code, [[\v^\s*(.{-})\s*$]])
  return parts[2]
end

local function invert_segment(code)
  -- The original had two leading branches for `not(...)` / `not ...`, but their
  -- patterns were double-quoted ("\v^\s*not...") so Vim stripped the backslashes
  -- at parse time, leaving broken regexes (`v^s*nots*...`) that never matched.
  -- They were dead in the original; omitting them preserves behavior.
  local parts = vim.fn.matchlist(code, [[\v^\s*(.+)(\=\=|\~\=)(.+)\s*$]])
  if #parts > 0 then
    local op = parts[3] == "==" and "~=" or "=="
    return parts[2] .. op .. parts[4]
  end
  return "not " .. code
end

local function invert(code)
  local parts = vim.fn.matchlist(code, [[\v^\s*(.{-})(and|or)\s*(.*)$]])
  if #parts > 0 then
    local first = invert_segment(parts[2])
    local rest = invert(parts[4])
    local operator = parts[3] == "and" and "or" or "and"
    return trim(first) .. " " .. operator .. " " .. rest
  else
    return trim(invert_segment(code))
  end
end

local function assert_to_if()
  local line = vim.fn.getline(".")
  local matches = vim.fn.matchlist(line, [[^\(\s*\)assert(\(.*\))\s*$]])
  if #matches < 3 then
    return
  end

  local indent = matches[2]
  local cond = invert(matches[3])

  local lines = {
    indent .. "if " .. cond .. " then",
    indent .. "  error('failed: " .. vim.fn.escape(cond, "'") .. "', 1)",
    indent .. "end",
  }
  vim.fn.setline(".", lines[1])
  vim.fn.append(".", { lines[2], lines[3] })
end

vim.keymap.set("n", "<leader>;a", assert_to_if) -- global in the original (no <buffer>)
