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

-- Timestamp highlighting {{{1
-- Make the "MM-DD" and "H:MM" parts of an ISO timestamp pop so the date and
-- time are quick to eyeball:
--   2026-06-24T08:38:07-06:00
--         ^^^^  ^^^^
-- We link to stock highlight groups (rather than hardcoding colors) so this
-- keeps working across colorscheme changes. `default = true` lets a colorscheme
-- override these if it defines them.
vim.api.nvim_set_hl(0, "JournalDate", { default = true, link = "Identifier" })
vim.api.nvim_set_hl(0, "JournalTime", { default = true, link = "Special" })

-- Highlighting is done with extmarks in a dedicated namespace. The namespace is
-- the self-clearing bit (like augroup `clear = true`): each repaint starts with
-- nvim_buf_clear_namespace, so re-running after a config edit never strands old
-- highlights. Extmarks are buffer-local, so every split gets them for free and
-- they ride along as the text shifts under edits.
local ns = vim.api.nvim_create_namespace("journal_timestamp_hl")

-- For "YYYY-MM-DD" / "Thh:mm", return the 0-based [start, end) byte range of the
-- significant part, dropping a leading zero on the first field. `field_start` is
-- the 1-based index of that field's first byte; `stop` is 1-based one-past-end.
local function significant_range(line, field_start, stop)
  local col = field_start - 1 -- 0-based start of the field
  if line:sub(field_start, field_start) == "0" then
    col = col + 1 -- skip the leading zero so "06-25" highlights as "6-25"
  end
  return col, stop - 1
end

local function paint(buf, row, line, pat, group)
  local init = 1
  while true do
    -- The `()` position captures mark the field start and the end of the match.
    local s, e, field_start, stop = line:find(pat, init)
    if not s then
      return
    end
    local from, to = significant_range(line, field_start, stop)
    vim.api.nvim_buf_set_extmark(buf, ns, row, from, {
      end_col = to,
      hl_group = group,
      -- Above treesitter's frontmatter highlighting (which draws at 100).
      priority = 200,
    })
    init = e + 1
  end
end

local function highlight_timestamps()
  local buf = 0
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for row, line in ipairs(lines) do
    -- MM-DD: skip a leading zero on the month.
    paint(buf, row - 1, line, "%d%d%d%d%-()%d%d%-%d%d()", "JournalDate")
    -- H:MM: anchored to the `T` so the timezone offset isn't matched; skip a
    -- leading zero on the hour.
    paint(buf, row - 1, line, "T()%d%d:%d%d()", "JournalTime")
  end
end

highlight_timestamps()

vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "BufWritePost", "BufReadPost" }, {
  buffer = 0,
  desc = "Repaint journal timestamp highlights",
  callback = highlight_timestamps,
})
-- }}}1

-- Autosync {{{1
-- Commit + pull --rebase + push on every save (see lua/journal_sync.lua).
require("journal_sync").attach()
-- }}}1
