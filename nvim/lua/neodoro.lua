local m = {}

local uv = vim.uv or vim.loop
--local estimate = "◯"
--local complete = "⬤"
--
local estimate = "□"
local complete = "■"
local miss = "ⅹ"
local tomato = "🍅"

-- make this a global so it will survive config reloads
if neodoro == nil then
  neodoro = {}
end

local namespace_name = "neodoro"
local namespace = vim.api.nvim_create_namespace(namespace_name)
local pomo_seconds = 25 * 60
local warning_seconds = 30

local function trim_spaces(str)
  local first_non_space = str:find("%S")
  return str:sub(first_non_space)
end

local function finish()
  local pos = vim.api.nvim_win_get_cursor(0)
  local tab = vim.api.nvim_win_get_tabpage(0)
  neodoro.pomo_timer:stop()
  vim.cmd("-tabnew")
  vim.t.tabname = tomato.." Pomodoro Done!"
  vim.t.is_pomo_tab = true

  local tmp_buf = vim.fn.bufnr("%")
  vim.cmd("b "..neodoro.pomo_buf)
  vim.cmd("silent bwipe! "..tmp_buf)

  local scratch_buffer = vim.api.nvim_create_buf(false, true)
  vim.cmd("vertical sbuffer" .. scratch_buffer)
  vim.api.nvim_buf_set_lines(scratch_buffer, 0, -1, false, {tomato.." Pomodoro Done!",""})
  vim.bo.bufhidden = "wipe"
end

local function get_status()
  local elapsed = vim.fn.reltimefloat(vim.fn.reltime(neodoro.start_time))
  local remaining = pomo_seconds - elapsed
  local negative = false
  if remaining < 0 then
    negative = true
    remaining = remaining * -1
  end
  local minutes = math.floor(remaining / 60)
  local seconds = remaining % 60
  return (tomato .. " %s%d:%02.0f"):format(negative and "-" or "", minutes, seconds)
end

local function update()
  local current_marks = vim.api.nvim_buf_get_extmarks(neodoro.pomo_buf, namespace, 0, -1, {})
  vim.api.nvim_buf_clear_namespace(neodoro.pomo_buf, namespace, 0, -1)
  if #current_marks == 0 then
    return
  end
  local pomo_mark = current_marks[1]
  local line = pomo_mark[2]

  local elapsed = vim.fn.reltimefloat(vim.fn.reltime(neodoro.start_time))
  local remaining = pomo_seconds - elapsed

  if remaining < -warning_seconds then
    finish()
    neodoro.mark_id = vim.api.nvim_buf_set_extmark(neodoro.pomo_buf, namespace, line, 0, {
      id = neodoro.mark_id,
      virt_text_pos = "eol",
      sign_text = tomato,
      virt_text = {
        {tomato.." Pomodoro Done!", "Error"}
      },
    })
    return
  elseif remaining < 0 then
    neodoro.mark_id = vim.api.nvim_buf_set_extmark(neodoro.pomo_buf, namespace, line, 0, {
      id = neodoro.mark_id,
      virt_text_pos = "eol",
      sign_text = tomato,
      virt_text = {
        {tomato.." Pomodoro Done!", "Error"}
      },
    })

    neodoro.task = (math.floor(-remaining) % 2 == 0) and "POMODORO DONE!!!" or ""
  else
    neodoro.mark_id = vim.api.nvim_buf_set_extmark(neodoro.pomo_buf, namespace, line, 0, {
      id = neodoro.mark_id,
      virt_text_pos = "eol",
      sign_text = tomato,
      virt_text = {
        {get_status(), "Error"}
      },
    })
  end
end

function m.statusline()
  if neodoro.pomo_buf == nil then
    return trim_spaces(vim.fn.strftime("%l:%M"))
  end
  local task = ""
  if neodoro.task then
    task = " %1*"..neodoro.task
  end
  return "%2*"..get_status()..task
end

local function process_task(task)
  task = trim_spaces(task)
  if task:sub(1,1) == "-" then
    task = task:sub(2)
  end
  task = trim_spaces(task)

  return task
end

function m.stop_pomodoro()
  local namespace = vim.api.nvim_create_namespace(namespace_name)
  if neodoro.pomo_buf then
    vim.api.nvim_buf_clear_namespace(neodoro.pomo_buf, namespace, 1, -1)
  end
  if neodoro.pomo_timer then
   neodoro.pomo_timer:stop()
  end
  neodoro = {}
end

function m.start_pomodoro()
  m.stop_pomodoro()

  neodoro.pomo_buf = vim.fn.bufnr('%')

  local pos = vim.fn.getcurpos('.')
  local line = pos[2] - 1
  vim.api.nvim_buf_clear_namespace(neodoro.pomo_buf, namespace, 1, -1)
  neodoro.mark_id = vim.api.nvim_buf_set_extmark(neodoro.pomo_buf, namespace, line, 0, {
    id = neodoro.mark_id,
    virt_text_pos = "eol",
    sign_text = tomato,
    virt_text = {
      {tomato.." 25:00", "Error"}
    },
  })

  neodoro.task = process_task(vim.fn.getline('.'))

  if vim.t.is_pomo_tab and vim.fn.tabpagenr('$') > 1 then
    vim.cmd.tabclose()
  end

  neodoro.start_time = vim.fn.reltime()
  neodoro.pomo_timer = uv.new_timer()
  neodoro.pomo_timer:start(1000, 1000, vim.schedule_wrap(function()
    local ok, res = pcall(update)
    if not ok then
      print(res)
      if neodoro.pomo_timer then
        neodoro.pomo_timer:stop()
      end
    end
  end))
end

function m.move_task()
  neodoro.pomo_buf = vim.fn.bufnr('%')
  local pos = vim.fn.getcurpos('.')
  local line = pos[2] - 1
  vim.api.nvim_buf_clear_namespace(neodoro.pomo_buf, namespace, 0, -1)
  neodoro.task = process_task(vim.fn.getline('.'))
  neodoro.mark_id = vim.api.nvim_buf_set_extmark(neodoro.pomo_buf, namespace, line, 0, {
    id = neodoro.mark_id,
    virt_text_pos = "eol",
    sign_text = tomato,
    virt_text = {
      {tomato.." Moving...", "Error"}
    },
  })
end

function m.increase_estimate()
  local line = vim.fn.getline('.')
  local new_line = line .. " " .. estimate
  vim.fn.setline('.', new_line)
end

function m.decrease_estimate()
  local line = vim.fn.getline('.')
  local new_line = line:gsub(estimate.."%s*", "", 1)
  vim.fn.setline('.', new_line)
end

function m.increase_complete()
  local line = vim.fn.getline('.')
  local new_line = line:gsub(estimate, complete, 1)
  if new_line == line then
    new_line = line .. " " .. miss
  end
  vim.fn.setline('.', new_line)
end

function m.decrease_complete()
  local line = vim.fn.getline('.')
  local new_line = line:reverse():gsub(miss:reverse(), estimate:reverse(), 1):reverse()
  if new_line == line then
    new_line = line:reverse():gsub(complete:reverse(), estimate:reverse(), 1):reverse()
  end
  vim.fn.setline('.', new_line)
end

return m
