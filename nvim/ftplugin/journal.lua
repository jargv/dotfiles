vim.opt.textwidth = 80

-- Frontmatter timestamps {{{1
-- Journal files carry YAML frontmatter at the top:
--   ---
--   created: 2026-06-24T08:38:07-06:00
--   modified: 2026-06-24T08:38:56-06:00
--   ---
-- We refresh `modified` on every write, and create the block (or fill in
-- missing keys) when it isn't there yet.

local function now_iso8601()
  local t = os.time()
  local stamp = os.date("%Y-%m-%dT%H:%M:%S", t)
  -- os.date("%z") gives e.g. "-0600"; turn it into "-06:00".
  local offset = os.date("%z", t):gsub("(%d%d)(%d%d)$", "%1:%2")
  return stamp .. offset
end

local function update_timestamps()
  local buf = 0
  local now = now_iso8601()
  -- The header lives at the very top; reading a slice is enough.
  local lines = vim.api.nvim_buf_get_lines(buf, 0, 50, false)

  if lines[1] == "---" then
    local close
    for i = 2, #lines do
      if lines[i] == "---" then
        close = i
        break
      end
    end

    if close then
      -- fm = the frontmatter block including both fences (1-based).
      local fm = {}
      for i = 1, close do
        fm[i] = lines[i]
      end

      local has_created, has_modified = false, false
      for i = 2, #fm - 1 do
        if fm[i]:match("^created:") then
          has_created = true
        end
        if fm[i]:match("^modified:") then
          has_modified = true
          fm[i] = "modified: " .. now
        end
      end

      if not has_modified then
        table.insert(fm, #fm, "modified: " .. now)
      end
      if not has_created then
        table.insert(fm, 2, "created: " .. now)
      end

      vim.api.nvim_buf_set_lines(buf, 0, close, false, fm)
      return
    end
  end

  -- No frontmatter block at all: prepend a fresh one.
  vim.api.nvim_buf_set_lines(buf, 0, 0, false, {
    "---",
    "created: " .. now,
    "modified: " .. now,
    "---",
    "",
  })
end

vim.api.nvim_create_user_command("JournalTouch", update_timestamps, {
  desc = "Refresh the journal frontmatter `modified` timestamp",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = 0,
  desc = "Update journal frontmatter timestamps on save",
  callback = function()
    -- Only touch files the user actually changed, so a plain `:w` on an
    -- unmodified buffer stays a no-op.
    if vim.bo.modified then
      update_timestamps()
    end
  end,
})
