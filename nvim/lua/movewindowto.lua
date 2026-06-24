-- Move the current window's buffer into the previous/next tab.
-- Migrated from autoload/MoveWindowTo.vim (MoveWindowTo#PrevTab/#NextTab).

local M = {}
local fn = vim.fn

local function move(forward)
  -- there is only one window
  if fn.tabpagenr("$") == 1 and fn.winnr("$") == 1 then return end

  local tab_nr = fn.tabpagenr("$")
  local cur_buf = fn.bufnr("%")
  local hidden_setting = vim.bo.bufhidden
  vim.bo.bufhidden = "hide"

  if forward then
    if fn.tabpagenr() < tab_nr then
      vim.cmd("close!")
      if tab_nr == fn.tabpagenr("$") then vim.cmd("tabnext") end
      vim.cmd("vsp")
    else
      vim.cmd("close!")
      vim.cmd("tabnew")
    end
  else
    if fn.tabpagenr() ~= 1 then
      vim.cmd("close!")
      if tab_nr == fn.tabpagenr("$") then vim.cmd("tabprev") end
      vim.cmd("vsp")
    else
      vim.cmd("close!")
      vim.cmd("0tabnew")
    end
  end

  -- open current buffer in the new window
  vim.cmd("b" .. cur_buf)
  vim.bo.bufhidden = hidden_setting
end

function M.next_tab() move(true) end
function M.prev_tab() move(false) end

return M
