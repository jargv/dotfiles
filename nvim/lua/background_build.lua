--[[
TODO:
- toggle for make on save
- figure out how to autoscroll the output buffers (or window)
- autodetect feature to automatically add a build (like the legacy version)
- statusline build status
- make it work well with scripting languages
- run command, but only if build succeeds (consider making this a separate key/feature)
]]

local fmtjson = require("fmtjson")

local editgroup = vim.api.nvim_create_augroup("build.edit.autogroup", {clear = true})

local function validateBuildConfig(config)
  for _,job in pairs(config) do
    if type(job.cwd) ~= "string" then
      error "job.cwd is required"
    elseif type(job.cmd) ~= "string" then
      error "job.cwd is required"
    end

    if job.name == nil then
      job.name = '['..job.cwd..'] '..job.cmd
    end

  end
end

local function editBuildConfig(config, callback)
  local file_name = vim.fn.tempname()
  vim.cmd('botright vsplit  '..file_name)
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
      validateBuildConfig(val)
      vim.defer_fn(function()
        vim.cmd("bwipe! "..buf)
        callback(val)
      end, 0 )
    end
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

local function stopJob(job)
  if job.id then
    vim.fn.jobstop(job.id)
    job.id = nil
  end
end

local function runJob(job)
  stopJob(job)

  -- create or clear the buffer
  if job.buf == nil then
    job.buf = vim.api.nvim_create_buf(false, true)
  else
    vim.api.nvim_buf_set_lines(job.buf, 0, -1, false, {})
  end

  local function on_out(_, output)
    vim.api.nvim_buf_set_lines(job.buf, -1, -1, false, output)
  end

  local function output(str) on_out(nil, {str}) end

  local job_descriptor = "'"..job.config.name.."'"

  output("starting job "..job_descriptor)

  local id = vim.fn.jobstart(job.config.cmd, {
    cwd = job.config.cwd,
    on_exit = function(_, exit_code, _)
      job.exit_code = exit_code
      job.id = nil
      output("job "..job_descriptor.." exited with code ".. job.exit_code)
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
  print "setting up a job"
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = job.config.pattern,
    group = jobGroup,
    callback = function() runJob(job) end
  })
end

local function setupBuildJobs(config, oldJobs)
  local jobGroup = vim.api.nvim_create_augroup("build.job.autogroup", {clear = true})

  local jobBuffersByName = {}
  for _,job in ipairs(oldJobs) do
    jobBuffersByName[job.config.name] = job.buf
    job.buf = nil
  end

  -- stop any current jobs, delete any buffers
  for _,job in ipairs(oldJobs) do
    stopJob(job)
  end

  -- set up the new job objects
  local newJobs = {}
  for _,jobConfig in ipairs(config) do
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

local buildConfig = {{
  global = true,
  name = "game",
  cwd = "/home/j/projects/game",
  cmd = "cmake --build build",
  pattern = "/home/j/projects/game/*.cpp"
}}
local buildJobs = {}

function api.editConfig()
  editBuildConfig(buildConfig, function(newConfig)
    buildConfig = newConfig
    buildJobs = setupBuildJobs(newConfig, buildJobs)
  end)
end

function api.loadErrors()
  local jobToShow = nil
  for _,job in pairs(buildJobs) do
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
  ]]):format(jobToShow.buf))
end

function api.viewOutput()
  for _,job in pairs(buildJobs) do
    if job.buf then
      vim.cmd(("botright vertical sbuffer %d"):format(job.buf))
    end
  end
end

function api.runAllNotRunning()
  local count_started = 0
  for _,job in pairs(buildJobs) do
    if job.id == nil then
      count_started = count_started + 1
      runJob(job)
    end
  end
  print(("started %d jobs"):format(count_started))
end

return api
