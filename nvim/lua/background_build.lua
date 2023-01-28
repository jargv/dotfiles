-- TODO:
--  * multi-line commands
--  * cmd_dir that can be different from dir
--  * bug when multiple afters + ext used for step

local fmtjson = require("fmtjson")
local fmtelapsed = require("fmtelapsed")

local starting_points = {
  cpp = {ext = {"cpp", "hpp"}, cmd = "cmake --build build"},
  hpp = {ext = {"cpp", "hpp"}, cmd = "cmake --build build"},
  ts = {cmd = "yarn run build"},
}

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

  output(">>> starting job "..job_descriptor)
  output(">>> " .. job.config.cmd)
  output("")

  local id = vim.fn.jobstart(job.config.cmd, {
    cwd = job.config.dir,
    on_exit = function(_, exit_code, _)
      job.exit_code = exit_code
      job.id = nil
      local elapsed = vim.fn.localtime() - job.start_time
      output(">>> job "..job_descriptor.." exited with code:".. job.exit_code)
      output(">>> time: "..fmtelapsed(elapsed))
      vim.cmd [[ doautocmd User BackgroundBuildJobStatusChanged ]]
    end,
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
    local job = {
      id = nil,
      buf = jobBuffersByName[jobConfig.name],
      exit_code = nil,
      config = jobConfig,
    }
    jobBuffersByName[jobConfig.name] = nil
    wire_up_job_autocmd(job, jobGroup)
    table.insert(newJobs, job)
  end

  -- clean up any buffers that weren't reused
  for _,buf in pairs(jobBuffersByName) do
    vim.api.nvim_buf_delete(buf, {force=true})
  end

  vim.api.nvim_create_autocmd("User BackgroundBuildJobStatusChanged", {
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
    if job.buf and job.exit_code ~= nil and job.exit_code ~= 0 then
      jobToShow = job
      break
    end
  end

  if jobToShow == nil then
    vim.cmd [[ cclose ]]
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

  local name = #build_jobs == 0 and "build" or nil

  table.insert(build_config.jobs, {
    dir = dir,
    ext = (starting_points[ext] or {}).extensinos or ext,
    cmd = (starting_points[ext] or {}).cmd,
    name = name
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
