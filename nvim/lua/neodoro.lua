local m = {}

local uv = vim.uv or vim.loop

-- make this a global so it will survive config reloads
if neodoro == nil then
  neodoro = {}
end

local namespace_name = "neodoro"
local pomo_seconds = 25 * 60
pomo_seconds = 5

local function finish()
  neodoro.pomo_timer:stop()
  vim.cmd("-tabnew")
  vim.t.tabname = "🍅 Pomodoro Done!"
  vim.t.is_pomo_tab = true

  local tmp_buf = vim.fn.bufnr("%")
  vim.cmd("b "..neodoro.pomo_buf)
  vim.cmd("silent bwipe! "..tmp_buf)

  local scratch_buffer = vim.api.nvim_create_buf(false, true)
  vim.cmd("vertical sbuffer" .. scratch_buffer)
  vim.api.nvim_buf_set_lines(scratch_buffer, 0, -1, false, {"🍅 Pomodoro Done!",""})
  vim.bo.bufhidden = "wipe"
end

local function update()
  local namespace = vim.api.nvim_create_namespace(namespace_name)
  local current_marks = vim.api.nvim_buf_get_extmarks(neodoro.pomo_buf, namespace, 0, -1, {})
  vim.api.nvim_buf_clear_namespace(neodoro.pomo_buf, namespace, 0, -1)
  if #current_marks == 0 then
    return
  end
  local pomo_mark = current_marks[1]
  local line = pomo_mark[2]

  local elapsed = vim.fn.reltimefloat(vim.fn.reltime(neodoro.start_time))
  local remaining = pomo_seconds - elapsed

  if remaining < 0 then
    vim.api.nvim_buf_set_extmark(neodoro.pomo_buf, namespace, line, 0, {
      virt_text_pos = "eol",
      sign_text = "🍅",
      virt_text = {
        {"🍅 Pomodoro Done!", "Error"}
      },
    })
    finish()
    return
  end

  local minutes = math.floor(remaining / 60)
  local seconds = remaining % 60
  vim.api.nvim_buf_set_extmark(neodoro.pomo_buf, namespace, line, 0, {
    virt_text_pos = "eol",
    sign_text = "🍅",
    virt_text = {
      {("🍅 %d:%02.0f"):format(minutes, seconds), "Error"}
    },
  })
end

function m.start_thing()
  local namespace = vim.api.nvim_create_namespace(namespace_name)

  if neodoro.pomo_buf then
    vim.api.nvim_buf_clear_namespace(neodoro.pomo_buf, namespace, 1, -1)
  end
  neodoro.pomo_buf = vim.fn.bufnr('%')

  local pos = vim.fn.getcurpos('.')
  local line = pos[2] - 1
  vim.api.nvim_buf_clear_namespace(neodoro.pomo_buf, namespace, 1, -1)
  vim.api.nvim_buf_set_extmark(neodoro.pomo_buf, namespace, line, 0, {
    virt_text_pos = "eol",
    sign_text = "P",
    virt_text = {
      {"🍅 25:00", "Error"}
    },
  })

  if neodoro.pomo_timer then
    neodoro.pomo_timer:stop()
  end

  if vim.t.is_pomo_tab and vim.fn.tabpagenr('$') > 1 then
    vim.cmd.tabclose()
  end

  neodoro.start_time = vim.fn.reltime()
  neodoro.pomo_timer = uv.new_timer()
  neodoro.pomo_timer:start(1000, 1000, vim.schedule_wrap(function()
    local ok, res = pcall(update)
    if not ok then
      print(res)
      neodoro.pomo_timer:stop()
    end
  end))
end

return m
