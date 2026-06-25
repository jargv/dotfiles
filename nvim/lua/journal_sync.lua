-- Autosync the journal git repo on save (GitJournal-style).
--
-- On every write we stage everything, commit, rebase on top of the remote, and
-- push -- all async via vim.system so the editor never blocks on the network.
-- The lock/queue state lives in module upvalues, which require() keeps as a
-- single session-wide singleton, so two journal buffers can't race the same repo.

local M = {}

-- State {{{1
local running = false
local queued = nil -- { root, msg } captured while a sync is in flight
local handle = nil -- the in-flight vim.system object (so exit can wait on it)
local exiting = false -- set on VimLeavePre so the queue drains synchronously

-- Sync {{{1
-- Stage + commit (only if something changed), integrate the remote, then push.
-- Exit 3 is reserved for "rebase hit a conflict and was aborted", so we can show
-- a clearer message and leave the repo in a clean (non-conflicted) state.
local SCRIPT = [[
git add -A
git diff --cached --quiet || git commit -q -m "$1" || exit 1
if ! git pull --rebase --autostash -q; then
  git rebase --abort >/dev/null 2>&1 || true
  exit 3
fi
git push -q
]]

local function cmd(msg)
  return { "sh", "-c", SCRIPT, "journal-sync", msg }
end

-- Warn (once, on the main loop) when a sync exits non-zero.
local function report(res)
  if res.code == 0 then
    return
  end
  local detail
  if res.code == 3 then
    detail = "rebase conflict -- resolve in the journal repo manually"
  elseif res.stderr and res.stderr ~= "" then
    detail = vim.trim(res.stderr)
  else
    detail = "exit " .. res.code
  end
  vim.schedule(function()
    vim.notify("journal autosync failed: " .. detail, vim.log.levels.WARN)
  end)
end

local function run(root, msg)
  running = true
  handle = vim.system(cmd(msg), { cwd = root, text = true, timeout = 30000 }, function(res)
    running = false
    handle = nil
    report(res)

    -- While exiting, flush() drains the queue synchronously -- don't reschedule
    -- (a vim.schedule callback would never fire once we're tearing down).
    if exiting then
      return
    end

    -- Coalesce saves that landed mid-sync into one follow-up run.
    local next_run = queued
    queued = nil
    if next_run then
      vim.schedule(function()
        run(next_run.root, next_run.msg)
      end)
    end
  end)
end

function M.sync(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    return
  end
  local root = vim.fs.root(file, ".git")
  if not root then
    vim.notify("journal autosync: no git repo for " .. file, vim.log.levels.WARN)
    return
  end

  local msg = ("autosync: %s @ %s"):format(
    vim.fn.fnamemodify(file, ":t"),
    os.date("%Y-%m-%dT%H:%M:%S")
  )

  if running then
    queued = { root = root, msg = msg }
    return
  end
  run(root, msg)
end

-- Flush {{{1
-- Async syncs are children of the Neovim process, so a plain :wq would kill the
-- in-flight push and silently drop anything still queued. On exit we block until
-- the running sync finishes, then drain the queue synchronously so the last save
-- always makes it to the remote.
function M.flush()
  exiting = true
  if handle then
    pcall(function()
      handle:wait(30000)
    end)
  end
  while queued do
    local q = queued
    queued = nil
    local ok, proc = pcall(vim.system, cmd(q.msg), { cwd = q.root, text = true, timeout = 30000 })
    if ok then
      report(proc:wait(30000))
    end
  end
end

-- Pull {{{1
-- Fetch + rebase remote changes (e.g. edits made on the phone) when a journal
-- file is opened, then reload the buffer if the file changed underneath us.
local PULL_SCRIPT = [[
git pull --rebase --autostash -q || { git rebase --abort >/dev/null 2>&1 || true; exit 3; }
]]

function M.pull(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  -- A save-sync already does pull --rebase; if one's in flight, let it cover us.
  if running then
    return
  end
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    return
  end
  local root = vim.fs.root(file, ".git")
  if not root then
    return
  end

  running = true
  handle = vim.system(
    { "sh", "-c", PULL_SCRIPT, "journal-pull" },
    { cwd = root, text = true, timeout = 30000 },
    function(res)
      running = false
      handle = nil
      report(res)
      if exiting then
        return
      end
      vim.schedule(function()
        -- Pick up remote edits only if the buffer is clean; checktime + the
        -- default 'autoread' reloads it silently. Unsaved work is left alone.
        if vim.api.nvim_buf_is_valid(buf) and not vim.bo[buf].modified then
          vim.api.nvim_buf_call(buf, function()
            vim.cmd("checktime")
          end)
        end
        -- Drain a save that landed while we were pulling.
        local next_run = queued
        queued = nil
        if next_run then
          run(next_run.root, next_run.msg)
        end
      end)
    end
  )
end

-- Attach {{{1
-- Called from ftplugin/journal.lua; wires the on-save trigger for this buffer
-- and fetches remote changes on open.
function M.attach()
  if vim.b.journal_sync_attached then
    return
  end
  vim.b.journal_sync_attached = true
  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = 0,
    desc = "Autosync journal repo to git on save",
    callback = function(args)
      M.sync(args.buf)
    end,
  })
  M.pull()
end

vim.api.nvim_create_user_command("JournalSync", function()
  M.sync()
end, { desc = "Sync the journal repo to git now" })

vim.api.nvim_create_autocmd("VimLeavePre", {
  desc = "Finish any pending journal autosync before exiting",
  callback = M.flush,
})
-- }}}1

return M
