--[[
TODO:
 - Variables in the strings with ${} syntax
 - hotkey to close just the build windows and nothing else
]]

local fmtjson = require("fmtjson")
local fmtelapsed = require("fmtelapsed")

local starting_points = {
  cpp = {ext = {"cpp", "hpp", "cxx"}, cmd = "cmake --build build", run = "build/exe"},
  hpp = {ext = {"cpp", "hpp", "cxx"}, cmd = "cmake --build build", run = "build/exe"},
  cxx = {ext = {"cpp", "hpp", "cxx"}, cmd = "cmake --build build", run = "build/exe"},
  go = {cmd = "go build", run = "ls"},
  ts = {cmd = "yarn run build"},
}

local editgroup = vim.api.nvim_create_augroup("build.edit.autogroup", {clear = true})

local function validateBuildConfig(config)
  if config.jobs == nil then
    config.jobs = {}
  end

  local jobs_by_name = {}
  for _,job in pairs(config.jobs) do
    -- ensure requried fields are available
    if type(job.dir) ~= "string" then
      error "job.dir is required"
    elseif type(job.cmd) ~= "string" then
      error "job.cmd is required"
    end

    -- trim the trailing '/' on dir
    if job.dir:sub(-1,-1) == '/' then
      job.dir = job.dir:sub(1,-2)
    end

    -- derive a name if none is given
    if job.name == nil then
      job.name = '['..job.dir..'] '..job.cmd
    end

    jobs_by_name[job.name] = job
  end

  -- ensure each "after" field points to a real job
  for _,job in pairs(config.jobs) do
    local dep_names = job.after
    if type(dep_names) ~= "table" then
      dep_names = {dep_names}
    end

    for _,dep_name in ipairs(dep_names) do
      if jobs_by_name[dep_name] == nil then
        error("invalid 'after' field job name: '"..dep_name.. "'")
      end
    end
  end
end

local function edit_build_config(config, callback)
  local save_file
  if config.save then
    save_file = config.save
  else
    config.save = vim.fn.tempname()
    save_file = vim.fn.tempname()
  end

  vim.cmd('botright vsplit  '..save_file)
  local buf = vim.fn.bufnr('%')
  vim.bo.filetype = "json"
  vim.bo.bufhidden = "wipe"

  local content = fmtjson(config)
  local lines = vim.fn.split(content, "\n")

  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = buf,
    group = editgroup,
    callback = function()
      local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local script = table.concat(buf_lines)
      local val = vim.fn.json_decode(script)

      -- if the save field was changed, also save to that file
      if val.save ~= save_file then
        vim.cmd("saveas! "..val.save)
      end

      validateBuildConfig(val)
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.cmd("bwipe! "..buf)
        end
        callback(val)
      end, 0 )
    end
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

local function get_buf_current_window(buf, tabpage)
  if buf == nil or not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  local buf_list = vim.fn.getbufinfo(buf)
  if #buf_list == 0 then
    return nil
  end
  for _, win_id in pairs(buf_list[1].windows) do
    if not tabpage or vim.api.nvim_win_get_tabpage(win_id) == tabpage then
      return win_id
    end
  end
  return nil
end

local function stop_job(job)
  -- Keep the window by making a new buffer for the job
  local old_window = get_buf_current_window(job.buf)
  local new_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_var(new_buf, "BackgroundBuildBuffer", true)
  if old_window then
    vim.api.nvim_win_set_buf(old_window, new_buf)
  end

  local oldbuf = job.buf
  job.buf = new_buf
  job.id = nil
  job.exit_code = nil
  job.start_time = nil

  -- clean up the old buffer (and process)
  if oldbuf and vim.api.nvim_buf_is_valid(oldbuf) then
    vim.api.nvim_buf_delete(oldbuf, {force=true})
  end
end

local function run_job(job)
  -- stop the job first
  stop_job(job)

  -- a nil exit code with a start_time means "running"
  job.start_time = vim.fn.localtime()
  job.stream_available = false

  local old_window = get_buf_current_window(job.buf)

  local output_window
  local tmp_floating_window
  if old_window and vim.api.nvim_win_is_valid(old_window) then
    output_window = old_window
  else
    -- there isn't an old window to use, use a tmp one
    tmp_floating_window = vim.api.nvim_open_win(job.buf, true, {
      relative = 'win',
      row = 0,
      col = 0,
      width = 200,
      height = 600,
    });
    output_window = tmp_floating_window
  end

  -- callback
  local function on_out(_)
    local current_tabpage = vim.api.nvim_get_current_tabpage()
    local win = get_buf_current_window(job.buf, current_tabpage)
    if win then
      local pos = vim.api.nvim_win_get_cursor(win)
      local line = pos[1]
      local last_line = vim.fn.line("$", win)
      if line == last_line then
        vim.fn.win_execute(win, "normal G")
      end
    end

    if job.config.stream then
      job.stream_available = true
    end
  end

  local starting_buf = job.buf
  local id = vim.api.nvim_win_call(output_window, function()
    return vim.fn.jobstart(job.config.cmd, {
      cwd = job.config.dir,
      on_exit = function(_, exit_code, _)
        if job.buf ~= starting_buf then
          return -- there's been a new version of the job created since this callback was created!
        end
        job.id = nil
        job.exit_code = exit_code
        if job.config.stream then
          -- streaming jobs should not stop
          job.exit_code = 1
        end
        vim.cmd [[ doautocmd User BackgroundBuildJobStatusChanged ]]
      end,
      term = true,
      on_stdout = on_out,
      on_stderr = on_out,
    })
  end)

  -- clean up the tmp window, if any
  if tmp_floating_window then
    vim.api.nvim_win_close(tmp_floating_window, {force=true})
  end

  if id == 0 then
    error "couldn't start job, invalid arguments (or job table is full!)"
  elseif id == -1 then
    error "couldn't start job, is command executable?"
  elseif id == nil then
    error "no job id!"
  end

  -- signal that the job has started
  job.id = id
  vim.cmd [[ doautocmd User BackgroundBuildJobStatusChanged ]]
end

local function wire_up_job_autocmd(job, jobGroup)
  local pattern = job.config.pattern

  -- pattern might also be built from the ext field
  if pattern == nil and job.config.ext ~= nil then
    local exts = job.config.ext
    if type(exts) == "string" then
      exts = {exts}
    end

    pattern = {}
    for _, ext in ipairs(exts) do
      table.insert(pattern, job.config.dir .. "/*" .. ext)
    end
  end

  -- nothing to wire up if no pattern!
  if pattern == nil then
    return
  end

  -- wire up
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = pattern,
    group = jobGroup,
    callback = function() run_job(job) end
  })
end

local function process_job_pipeline(jobs)
  -- collect some info about the jobs
  local jobs_by_name = {}
  local jobs_to_check = {}
  for _, job in pairs(jobs) do
    if job.config.after ~= nil then
      table.insert(jobs_to_check, job)
    end
    jobs_by_name[job.config.name] = job
  end

  -- run the jobs that are ready
  for _, job in ipairs(jobs_to_check) do
    -- grab the names of the dep jobs
    local dep_names = job.config.after
    if type(dep_names) ~= "table" then
      dep_names = {dep_names}
    end

    -- get the deps from their names, replacing nil with false
    local deps = {}
    for _, dep_name in ipairs(dep_names) do
      table.insert(deps, jobs_by_name[dep_name] or false)
    end

    -- check status of deps
    local deps_all_succeeded = true
    local some_deps_missing = false
    local some_deps_still_running = false
    local some_deps_not_started = false

    for _, after_job in ipairs(deps) do
      if after_job == false then
        some_deps_missing = false
        goto continue
      end

      if after_job.exit_code ~= 0 then
        deps_all_succeeded = false
      end

      if after_job.id ~= nil then
        some_deps_still_running = true
      end

      if after_job.id == nil and after_job.exit_code == nil then
        some_deps_not_started = true
      end
      ::continue::
    end

    local already_running = job.id ~= nil
    local already_finished = job.exit_code ~= nil

    if some_deps_missing or some_deps_not_started or some_deps_still_running or (already_running and not deps_all_succeeded) then
      stop_job(job)
    elseif not already_running and not already_finished and deps_all_succeeded then
      run_job(job)
    end
  end
end

local function setup_build_jobs(config, oldJobs)
  local jobGroup = vim.api.nvim_create_augroup("background_build.job.autogroup", {clear = true})

  -- collect current valid buffers so they can be moved to new jobs by name
  local jobBuffersByName = {}
  for _,job in ipairs(oldJobs) do
    if job.buf ~= nil and vim.api.nvim_buf_is_valid(job.buf) then
      jobBuffersByName[job.config.name] = job.buf
      job.buf = nil
    end
  end

  -- stop any current jobs
  for _,job in ipairs(oldJobs) do
    stop_job(job)
  end

  -- set up the new job objects
  local newJobs = {}
  for _,jobConfig in ipairs(config.jobs) do
    if jobConfig.skip then
      goto continue
    end
    local job = {
      id = nil,
      buf = jobBuffersByName[jobConfig.name],
      exit_code = nil,
      config = jobConfig,
    }
    jobBuffersByName[jobConfig.name] = nil
    if config.build_on_save ~= false then
      wire_up_job_autocmd(job, jobGroup)
    end
    table.insert(newJobs, job)
    ::continue::
  end

  -- clean up any buffers that weren't reused
  for _,buf in pairs(jobBuffersByName) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, {force=true})
    end
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "BackgroundBuildJobStatusChanged",
    group = jobGroup,
    callback = function ()
      vim.defer_fn(function()
        process_job_pipeline(newJobs)
      end, 0)
    end
  })

  return newJobs
end

local api = {}

if build_config == nil then
  build_config = {jobs = {}}
end

if build_jobs == nil then
  build_jobs = {}
end

function api.edit_config()
  edit_build_config(build_config, function(newConfig)
    build_config = newConfig
    build_jobs = setup_build_jobs(newConfig, build_jobs)
  end)
end

function api.load_errors()
  local job_to_show = nil
  local buildJob = nil
  for _,job in pairs(build_jobs) do
    local failed = job.exit_code ~= nil and job.exit_code ~= 0
    local stream_available = job.config.stream and job.stream_available
    local should_open = job.buf and (failed or stream_available)
    if job.config.name == "build" then
      buildJob = job
    end
    if should_open then
      job_to_show = job
      break
    end
  end

  if job_to_show == nil and buildJob ~= nil then
    job_to_show = buildJob
  end

  if job_to_show == nil then
    vim.cmd.cclose()
    return
  end

  local starting_dir = vim.fn.getcwd()
  vim.cmd(([[
    cd %s
    cclose
    cbuffer %s
    cwindow
    exec "normal \<cr>"
    cd %s
  ]]):format(job_to_show.config.dir, job_to_show.buf, starting_dir))

  if job_to_show.config.stream then
    -- clear the buffer
    run_job(job_to_show)
  end
end

function api.open_error_output_buffers()
  local starting_win = vim.api.nvim_get_current_win()
  for _, job in ipairs(build_jobs) do
    if job.buf then
      local info = vim.fn.getbufinfo(job.buf)
      -- close all windows. Failed jobs will be reopened later
      if #info ~= 0 then
        for _,win in ipairs(info[1].windows) do
          vim.api.nvim_win_close(win, {force=true})
        end
      end
    end
  end

  for _, job in ipairs(build_jobs) do
    local failed = job.exit_code ~= nil and job.exit_code ~= 0
    local should_open = job.buf and failed
    if should_open then
      vim.cmd(([[
        botright vertical sbuffer %d
        normal G
        setlocal nonumber
      ]]):format(job.buf))
    end
  end
  vim.cmd [[
    wincmd =
  ]]
  vim.api.nvim_set_current_win(starting_win)
end

function api.toggle_open_all_output_buffers(stacked)
  local starting_win = vim.api.nvim_get_current_win()
  local windows_to_close = {}
  local any_opened = false
  local current_tabpage = vim.api.nvim_get_current_tabpage()

  local vertical = "vertical"
  local dir = stacked and "topleft" or "botright"
  for _,job in pairs(build_jobs) do

    if not job.buf or not vim.api.nvim_buf_is_valid(job.buf) then
      -- make a buffer so we can open a window
      job.buf = vim.api.nvim_create_buf(false, true)
    end

    local win_on_current_tab = get_buf_current_window(job.buf, current_tabpage)
    if win_on_current_tab then
      table.insert(windows_to_close, win_on_current_tab)
      goto continue
    end

    any_opened = true
    vim.cmd(([[
      %s %s sbuffer %d
      normal G
      setlocal nonumber
    ]]):format(dir, vertical, job.buf))

    if stacked then
      vertical = ""
      dir = "belowright"
    end

    ::continue::
  end

  if not any_opened then
    for _, win_id in ipairs(windows_to_close) do
      if vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
      end
    end
  end
  vim.api.nvim_set_current_win(starting_win)
end

function api.run_all_not_running()
  for _,job in pairs(build_jobs) do
    if job.id == nil and job.config.after == nil then
      run_job(job)
    end
  end
end

function api.stop_all()
  for _,job in pairs(build_jobs) do
    stop_job(job)
  end
end

function api.add_from_current_file()
  local ext = vim.fn.expand("%:e")
  if ext == "json" then
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local script = table.concat(buf_lines)
    local new_config = vim.fn.json_decode(script)
    validateBuildConfig(new_config)
    build_jobs = setup_build_jobs(new_config, build_jobs)
    build_config = new_config
    print "loaded as build config"
    return
  end

  local dir = vim.fn.expand("%:p:h")

  local has_build = starting_points[ext] ~= nil

  if has_build then
    table.insert(build_config.jobs, {
      name = "build",
      dir = dir,
      ext = (starting_points[ext] or {}).ext or ext,
      cmd = (starting_points[ext] or {}).cmd,
    })
  end

  table.insert(build_config.jobs, {
    name = "run",
    dir = dir,
    after = has_build and "build" or nil,
    ext = (not has_build) and ext,
    cmd = (starting_points[ext] or {run = ("./%s"):format(vim.fn.expand("%:t"))}).run,
  })

  api.edit_config()
end

function api.statusline()
  local parts = {}
  for _,job in pairs(build_jobs) do
    if job.config.stream then
      if job.exit_code then
        -- stream jobs should never stop
        table.insert(parts, "%4*")
        table.insert(parts, job.config.name..": stream stopped" .. job.exit_code)
      elseif job.id == nil then
        table.insert(parts, "%1*")
        table.insert(parts, job.config.name..": stream not started")
      elseif job.stream_available then
        table.insert(parts, "%6*")
        table.insert(parts, job.config.name..": stream available")
      else
        table.insert(parts, "%3*")
        table.insert(parts, job.config.name..": stream pending")
      end
    elseif job.start_time == nil then
      table.insert(parts, "%1*")
      table.insert(parts, job.config.name..": not started")
    elseif job.exit_code == nil then
      local elapsed = vim.fn.localtime() - job.start_time
      table.insert(parts, "%2*")
      table.insert(parts, job.config.name..": "..fmtelapsed(elapsed))
    elseif job.exit_code == 0 then
      table.insert(parts, "%3*")
      table.insert(parts, job.config.name..": success")
    else
      table.insert(parts, "%4*")
      table.insert(parts, job.config.name..": failed")
    end
    table.insert(parts, "%5* | ")
  end

  table.insert(parts, "%#StatusLine#")
  return table.concat(parts)
end

function api.clear_config()
  build_config = {}
  validateBuildConfig(build_config)
  build_jobs = setup_build_jobs(build_config, build_jobs)
  print "build config cleared"
end

local function get_step_config_by_name(name)
  for _,job in ipairs(build_config.jobs) do
    if job.name == name then
      return job
    end
  end
  return nil
end

local function get_job_by_name(name)
  for _,job in ipairs(build_jobs) do
    if job.config.name == name then
      return job
    end
  end
end

function api.toggle_step_by_name(name)
  local job = get_step_config_by_name(name)
  if job then
    job.skip = not job.skip
    build_jobs = setup_build_jobs(build_config, build_jobs)
  end
end


function api.debug_run_step(break_first)
  local run_job = get_step_config_by_name("run")
  if not run_job then
    return
  end

  local cmd = run_job.cmd
  cmd = cmd:gsub("%d?>.*$", "") -- strip off any redirection, it breaks gdb tui

  local break_option = ""
  if break_first then
    local fname = vim.fn.expand("%:p")
    local line = vim.fn.line(".")
    break_option = ('-ex \\"break %s:%d\\"'):format(fname, line)
  end

  vim.cmd("tabnew term://"..run_job.dir.."///usr/bin/gdb --tui "..break_option.." --args ".. cmd)
end

function api.attach_debugger_to_running_step(step_name)
  local job = get_job_by_name(step_name)
  if not job then
    print "not a job"
    return
  end

  if not job.id then
    print "no id"
    return
  end

  local cmd = job.config.cmd
  cmd = cmd:gsub("%d?>.*$", "") -- strip off any redirection, it breaks gdb tui

  -- this only gets us the parent pid because the job is running in a shell
  local parent_pid = vim.fn.jobpid(job.id)
  local output = vim.fn.systemlist("pgrep -P "..parent_pid)
  if #output == 0 then
    output = {parent_pid}
  end
  local pid = output[1]
  cmd = "tabnew term://"..job.config.dir.."///usr/bin/gdb --tui -p ".. pid .. " " .. cmd
  print(cmd)
  vim.cmd(cmd)
end

function api.show_jobs()
  vim.sendkeys(":print(vim.inspect(build_jobs))")
end

return api
