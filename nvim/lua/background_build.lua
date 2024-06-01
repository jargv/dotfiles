--[[
TODO:
 - Variables in the strings with ${} syntax
 - hotkey to close just the build windows and nothing else
]]

local fmtjson = require("fmtjson")
local fmtelapsed = require("fmtelapsed")

local starting_points = {
  cpp = {ext = {"cpp", "hpp", "cxx"}, cmd = "cmake --build build", run = "build/Debug/exe"},
  hpp = {ext = {"cpp", "hpp", "cxx"}, cmd = "cmake --build build", run = "build/Debug/exe"},
  cxx = {ext = {"cpp", "hpp", "cxx"}, cmd = "cmake --build build", run = "build/Debug/exe"},
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

local function stop_job(job)
  if job.id then
    vim.fn.jobstop(job.id)
    vim.fn.jobwait({job.id}, 3)
    if job.id ~= nil then
      error ("ERROR: job %d was not cleared, exit handler was not run!"):format(job.id)
    end
  end
  job.exit_code = nil
  job.start_time = nil
end

local function run_job(job)
  stop_job(job)

  -- create or clear the buffer
  if job.buf == nil or not vim.api.nvim_buf_is_valid(job.buf) then
    job.buf = vim.api.nvim_create_buf(false, true)
  else
    vim.api.nvim_buf_set_lines(job.buf, 0, -1, false, {})
  end

  -- output helpers
  local function on_out(_, output)
    local wins_to_scroll = {}
    local windows = vim.fn.win_findbuf(job.buf)
    for _, win in ipairs(windows) do
      local pos = vim.api.nvim_win_get_cursor(win)
      local line = pos[1]
      local last_line = vim.fn.line("$", win)
      if line == last_line then
        table.insert(wins_to_scroll, win)
      end
    end

    for i, line in pairs(output) do
      output[i] = line:gsub("[\r\n]", "")
    end

    vim.api.nvim_buf_set_lines(job.buf, -1, -1, false, output)
    if job.config.stream then
      job.stream_available = true
    end

    for _, win in ipairs(wins_to_scroll) do
      vim.fn.win_execute(win, "normal G")
    end
  end
  local function output(str) on_out(nil, {str}) end

  -- a nil exit code means "running"
  job.exit_code = nil
  job.start_time = vim.fn.localtime()

  local job_descriptor = "'"..job.config.name.."'"

  output(">>> starting job "..job_descriptor)
  output(">>> " .. job.config.cmd)
  output("")
  job.stream_available = false

  local id = vim.fn.jobstart(job.config.cmd, {
    cwd = job.config.dir,
    on_exit = function(_, exit_code, _)
      job.exit_code = exit_code
      if job.config.stream then
        -- streaming jobs should stop
        job.exit_code = 1
      end
      job.id = nil
      local elapsed = vim.fn.localtime() - job.start_time
      output(">>> job "..job_descriptor.." exited with code:".. job.exit_code)
      output(">>> time: "..fmtelapsed(elapsed))
      vim.cmd [[ doautocmd User BackgroundBuildJobStatusChanged ]]
    end,
    pty = true,
    on_stdout = on_out,
    on_stderr = on_out,
  })
  if id == 0 then
    error "couldn't start job, invalid arguments (or job table is full!)"
  elseif id == -1 then
    error "couldn't start job, is command executable?"
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
    -- grap the names of the dep jobs
    local dep_names = job.config.after
    if type(dep_names) ~= "table" then
      dep_names = {dep_names}
    end

    -- get the deps from their names
    local deps = {}
    for _, dep_name in ipairs(dep_names) do
      table.insert(deps, jobs_by_name[dep_name])
    end

    -- check status of deps
    local deps_all_succeeded = true
    local some_deps_still_running = false
    local some_deps_not_started = false

    for _, after_job in ipairs(deps) do
      if after_job.exit_code ~= 0 then
        deps_all_succeeded = false
      end

      if after_job.id ~= nil then
        some_deps_still_running = true
      end

      if after_job.id == nil and after_job.exit_code == nil then
        some_deps_not_started = true
      end
    end

    local already_running = job.id ~= nil
    local already_finished = job.exit_code ~= nil

    if some_deps_not_started or some_deps_still_running or (already_running and not deps_all_succeeded) then
      stop_job(job)
    elseif not already_running and not already_finished and deps_all_succeeded then
      -- share the output buffer from a unique dep
      if #deps == 1 then
        job.buf = deps[1].buf
      end
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
    wire_up_job_autocmd(job, jobGroup)
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
  local jobToShow = nil
  for _,job in pairs(build_jobs) do
    local failed = job.exit_code ~= nil and job.exit_code ~= 0
    local stream_available = job.config.stream and job.stream_available
    local should_open = job.buf and (failed or stream_available)
    if should_open then
      jobToShow = job
      break
    end
  end

  if jobToShow == nil then
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
  ]]):format(jobToShow.config.dir, jobToShow.buf, starting_dir))

  if jobToShow.config.stream then
    -- clear the buffer
    jobToShow.stream_available = false
    vim.api.nvim_buf_set_lines(jobToShow.buf, 0, -1, false, {})
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
  local dir = (stacked or #build_jobs == 1) and "botright" or "topleft"
  for i,job in pairs(build_jobs) do
    if not job.buf then
      goto continue
    end

    local buf_list = vim.fn.getbufinfo(job.buf)
    local win_on_current_tab = nil

    for _, win_id in pairs(buf_list[1].windows) do
      if vim.api.nvim_win_get_tabpage(win_id) == current_tabpage then
        win_on_current_tab = win_id
        break;
      end
    end

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
    elseif i == 1 then
      dir = "botright"
    elseif i == 2 then
      dir = "belowright"
      vertical = ""
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

  table.insert(build_config.jobs, {
    name = "build",
    dir = dir,
    ext = (starting_points[ext] or {}).ext or ext,
    cmd = (starting_points[ext] or {}).cmd,
  })

  table.insert(build_config.jobs, {
    name = "run",
    dir = dir,
    after = "build",
    cmd = (starting_points[ext] or {}).run,
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
        table.insert(parts, job.config.name..": stream stopped")
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

local function get_step_named_run()
  for _,job in ipairs(build_config.jobs) do
    if job.name == "run" then
      return job
    end
  end
  return nil
end

function api.toggle_run_step()
  local run_job = get_step_named_run()
  if run_job then
    run_job.skip = not run_job.skip
    build_jobs = setup_build_jobs(build_config, build_jobs)
  end
end

function api.debug_run_step(break_first)
  local run_job = get_step_named_run()
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

return api
