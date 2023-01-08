--[[
TODO:
- run command, but only if build succeeds (consider making this a separate key/feature)
consider:
- more granular control of job stopping and starting
- cancelled status instead of "failed"
]]

local fmtjson = require("fmtjson")
local fmtelapsed = require("fmtelapsed")

local editgroup = vim.api.nvim_create_augroup("build.edit.autogroup", {clear = true})

local function validateBuildConfig(config)
  if config.jobs == nil then
    config.jobs = {}
  end

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
  end
end

local function editBuildConfig(config, callback)
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
        vim.cmd("bwipe! "..buf)
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
end

local function run_job(job)
  stop_job(job)

  -- create or clear the buffer
  if job.buf == nil then
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

    vim.api.nvim_buf_set_lines(job.buf, -1, -1, false, output)

    for _, win in ipairs(wins_to_scroll) do
      vim.fn.win_execute(win, "normal G")
    end
  end
  local function output(str) on_out(nil, {str}) end

  -- a nil exit code means "running"
  job.exit_code = nil
  job.start_time = vim.fn.localtime()

  local job_descriptor = "'"..job.config.name.."'"

  output("starting job "..job_descriptor)

  local id = vim.fn.jobstart(job.config.cmd, {
    cwd = job.config.dir,
    on_exit = function(_, exit_code, _)
      job.exit_code = exit_code
      job.id = nil
      local elapsed = vim.fn.localtime() - job.start_time
      output("job "..job_descriptor.." exited with code:".. job.exit_code)
      output("time: "..fmtelapsed(elapsed))
    end,
    on_stdout = on_out,
    on_stderr = on_out,
  })
  if id == 0 then
    error "couldn't start job, invalid arguments (or job table is full!)"
  elseif id == -1 then
    error "couldn't start job, is command executable?"
  end

  job.id = id
end

local function wireUpJob(job, jobGroup)
  local pattern = job.config.pattern

  -- pattern might also be built from the ext field
  if pattern == nil and job.config.ext ~= nil then
    local exts = job.config.ext
    if type(exts) == "string" then
      exts = {exts}
    end

    pattern = {}
    for i, ext in ipairs(exts) do
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

local function setup_build_jobs(config, oldJobs)
  local jobGroup = vim.api.nvim_create_augroup("build.job.autogroup", {clear = true})

  -- collect current buffers so they can be moved to new jobs by name
  local jobBuffersByName = {}
  for _,job in ipairs(oldJobs) do
    jobBuffersByName[job.config.name] = job.buf
    job.buf = nil
  end

  -- stop any current jobs
  for _,job in ipairs(oldJobs) do
    stop_job(job)
  end

  -- set up the new job objects
  local newJobs = {}
  for _,jobConfig in ipairs(config.jobs) do
    local job = {
      id = nil,
      buf = jobBuffersByName[jobConfig.name],
      exit_code = nil,
      config = jobConfig,
    }
    jobBuffersByName[jobConfig.name] = nil
    wireUpJob(job, jobGroup)
    table.insert(newJobs, job)
  end

  -- clean up any buffers that weren't reused
  for _,buf in pairs(jobBuffersByName) do
    vim.api.nvim_buf_delete(buf, {force=true})
  end

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
  editBuildConfig(build_config, function(newConfig)
    build_config = newConfig
    build_jobs = setup_build_jobs(newConfig, build_jobs)
  end)
end

function api.load_errors()
  local jobToShow = nil
  for _,job in pairs(build_jobs) do
    if job.buf then
      jobToShow = job
      break
    end
  end

  if jobToShow == nil then
    print("no jobs to show")
    return
  end

  vim.cmd(([[
    cclose
    cbuffer %s
    cwindow
    exec "normal \<cr>"
  ]]):format(jobToShow.buf))
end

function api.view_output()
  for _,job in pairs(build_jobs) do
    if job.buf then
      vim.cmd(([[
        botright vertical sbuffer %d
        normal G
        setlocal nonumber
      ]]):format(job.buf))
    end
  end
end

function api.run_all_not_running()
  local count_started = 0
  for _,job in pairs(build_jobs) do
    if job.id == nil then
      count_started = count_started + 1
      run_job(job)
    end
  end
  print(("started %d jobs"):format(count_started))
end

function api.stop_all()
  local count_stopped = 0
  for _,job in pairs(build_jobs) do
    if job.id ~= nil and job.exit_code == nil then
      count_stopped = count_stopped + 1
      stop_job(job)
    end
  end
  print(("stopped %d jobs"):format(count_stopped))
end

function api.add_from_current_file()
  local dir = vim.fn.expand("%:p:h")
  local dir_before_src = dir:match("(.*)/src.*")

  table.insert(build_config.jobs, {
    dir = dir_before_src or dir,
    ext = vim.fn.expand("%:e")
  })
  api.edit_config()
end

function api.statusline()
  local parts = {}
  local sep = ""
  for _,job in pairs(build_jobs) do
    table.insert(parts, sep)
    sep = "%5* | "
    if job.start_time == nil then
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

return api
