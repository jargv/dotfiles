--[[
TODOS:
  - hotkey that opens every file in windows or tabs or buffers
  - recompute gitato view width when status changes
  - Fix bug when status is longer than the window (rare)
  - Completion help when changing diff_branch
  - key for refreshing status (r)
  - hotkeys work with tig view
  - if not in a git repo, fallback to the cwd and check again
consider:
  - clean up the viewer code by using win_execute function
  - set the filetype of the diff buffer to match the source buffer
  - move the cursor along with the file when the status updates
  - history view for single file
]]
local gitato = {}
local group = "gitato.autogroup"
local extra_width_in_main_view = 6
local viewer_help = {
  "## keys",
  "## a - Add the file",
  "## A - Add all files",
  "## R - Restore the file (checkout)",
  "## d - delete the file",
  "## b - change the diff branch",
  "## h - git log (tig)",
  "## . - open terminal in the repo root",
  "## c - commit",
  "## q - quit"
}

local current_diff_buffer = nil

function gitato.diff_off()
  vim.cmd("diffoff!")
  if current_diff_buffer ~= nil
    and vim.api.nvim_buf_is_valid(current_diff_buffer) then
    vim.cmd("bwipe! "..current_diff_buffer)
  end
  current_diff_buffer = nil
end

function gitato.get_repo_root(dir)
  dir = dir or vim.fn.expand("%:p")
  local dir = vim.fn.fnamemodify(vim.fn.resolve(dir), ":h")
  local result = vim.fn.systemlist("cd "..dir.." && git rev-parse --show-toplevel")
  local error = vim.api.nvim_get_vvar("shell_error")
  if error ~= 0 or #result == 0 then
    print "shell error"
    return nil
  end
  return result[1]
end

function gitato.toggle_diff_against_git_ref(ref)
  if current_diff_buffer ~= nil then
    gitato.diff_off()
    return
  end

  local git_root = gitato.get_repo_root()
  if git_root == nil then
    print("ERROR: Is this a git repo?")
    return
  end

  local file = vim.fn.resolve(vim.fn.expand("%:p"))
  if file:sub(1, #git_root) == git_root then
    file = file:sub(#git_root + 2)
  else
    file = "./"..file
  end

  local diff_contents = vim.fn.systemlist("cd "..git_root.." && git show ".. ref..':'..file)
  local error = vim.api.nvim_get_vvar("shell_error")
  if error ~= 0 then
    print(table.concat(diff_contents, "\n"))
    print("ERROR: Is this a git repo root?")
    return
  end

  vim.cmd("leftabove vnew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  current_diff_buffer = vim.fn.bufnr("%")
  vim.api.nvim_buf_set_lines(current_diff_buffer, 0, 1, false, diff_contents)
  vim.cmd(":diffthis")
  vim.cmd("normal l")
  vim.cmd(":diffthis")
end

local function parse_status_line(line)
  local status, file = string.match(line, "^(..)%s*(%S*)$")
  return status, file
end

local function shell_cmd(cmd)
  local root = gitato.get_repo_root()
  local result = vim.fn.systemlist(("cd %s && %s"):format(root, cmd))
  if 0 ~= vim.api.nvim_get_vvar("shell_error") then
    print(table.concat(result, '\n'))
    return nil
  end
  return result
end

local function git_cmd(c)
  return shell_cmd("git "..c)
end

function gitato.get_status(diff_branch)
  if diff_branch ~= nil then
    return git_cmd(("diff --name-status %s"):format(diff_branch))
  end

  return git_cmd("status -sb")
end


function gitato.status_foreach(diff_branch, cb)
  local status_lines = gitato.get_status(diff_branch)
  for _,line in ipairs(status_lines) do
    local status, file = parse_status_line(line)
    cb(status, file)
  end
end

function gitato.commit(repo_root, post_commit)
  -- first get the git status
  local git_status = vim.fn.systemlist(
    ("cd %s && git commit -v -v --dry-run"):format(repo_root)
  )
  if 0 ~= vim.api.nvim_get_vvar("shell_error") then
    print("error getting git status... anything comitted?")
    return
  end

  -- prepare a new buffer for the commit message
  local file_name = vim.fn.tempname()
  vim.cmd("botright split "..file_name)
  local buffer = vim.fn.bufnr('%')
  vim.bo.syntax = "gitcommit"
  vim.bo.bufhidden = "wipe"
  vim.bo.buflisted = false
  vim.bo.modified = false

  -- add the message into the buffer
  local message = {
    "## enter commit message above, then save to commit",
  }
  for _,line in ipairs(git_status) do
    table.insert(message, "# "..line)
  end
  vim.api.nvim_buf_set_lines(buffer, -1, -1, false, message)

  -- commit when the buffer is written
  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = buffer,
    callback = function()
      local cmd = ("cd %s && git commit --cleanup=strip --file=%s"):format(repo_root, file_name)
      vim.fn.termopen(cmd, {
        on_exit = function()
          vim.cmd("bwipe! ".. buffer)
          if post_commit then post_commit() end
        end
      })
    end
  })
end

function gitato.open_viewer(diff_branch)
  vim.api.nvim_create_augroup(group, {clear=true})

  -- find the repo root of the current file
  local git_repo_root = gitato.get_repo_root()
  if git_repo_root == nil then
    print("ERROR: Is this a git repo?")
    return
  end

  if git_repo_root:sub(-1,-1) ~= "/" then
    git_repo_root = git_repo_root .. "/"
  end

  local main_buf = vim.api.nvim_create_buf(false, true)
  local main_buf_width = 0
  local main_buf_height = 0
  local current_view_window = nil
  local viewing_log = false

  local function draw_status(status)
    local line_for_help = main_buf_height - #viewer_help
    local lines = {}
    if diff_branch ~= nil then
      table.insert(lines, ("## diff vs %s"):format(diff_branch))
    end

    for i = 1,main_buf_height+1 do
      if i <= #status then
        table.insert(lines, status[i])
      elseif i > line_for_help then
        table.insert(lines, viewer_help[i - line_for_help])
      else
        table.insert(lines, "")
      end
    end
    vim.api.nvim_buf_set_lines(main_buf, 0, -1, false, lines)
  end

  local function get_and_draw_status()
    local status = gitato.get_status(diff_branch)
    if status ~= nil then
      draw_status(status)
    end
  end

  local function get_status_and_file_from_line(line)
    local line = vim.fn.getline(line)

    -- grab the file and status from the line
    local status, file = parse_status_line(line)

    -- skip comment lines
    if string.match(line, "^#") then
      return nil, nil
    end

    -- skip empty files
    if file == "" or file == nil then
      return nil, nil
    end

    return status, file
  end

  local function get_status_and_file_from_current_line()
    return get_status_and_file_from_line('.')
  end

  local function close_view_window()
    gitato.diff_off()
    if current_view_window ~= nil and vim.api.nvim_win_is_valid(current_view_window) then
      vim.api.nvim_win_close(current_view_window, false)
    end
    viewing_log = false
    current_view_window = nil
  end

  local function view_diff_for_current_file()
    -- if nil, clean up the current diff windows
    local status, file = get_status_and_file_from_current_line()

    if file == nil or file == "" then
      close_view_window()
      return
    end

    -- Don't reload the file that is already loaded for viewing
    if current_view_window ~= nil and vim.api.nvim_win_is_valid(current_view_window) then
      local absolute_file = git_repo_root .. file
      local current_file_buffer = vim.api.nvim_win_get_buf(current_view_window)
      local current_file = vim.fn.resolve(vim.api.nvim_buf_get_name(current_file_buffer))
      -- print("current_file: ", current_file, "(", file, ")", "[", absolute_file, "]")
      if absolute_file == current_file then
        return
      end
    end

    -- close the current diff window before opening another
    close_view_window()

    if current_view_window == nil
    or not vim.api.nvim_win_is_valid(current_view_window)
    then
      -- create the window
      local total_width = vim.api.nvim_win_get_width(0)
      local diff_window_width = total_width - main_buf_width
      vim.cmd(""..diff_window_width.."vsplit "..git_repo_root..file)
      gitato.diff_off()
      if status ~= "??" then
        gitato.toggle_diff_against_git_ref(
          diff_branch or "HEAD"
        )
      end
      vim.cmd("normal ggM")
      current_view_window = vim.fn.win_getid(vim.fn.winnr())
    else
      error("unexpected path taken...")
    end
    vim.cmd("normal ggM")
    vim.cmd("normal hh")
    vim.wo.winfixwidth = true
  end

  local function view_log()
    if viewing_log then
      return
    end

    close_view_window()
    local total_width = vim.api.nvim_win_get_width(0)
    local diff_window_width = total_width - main_buf_width
    vim.cmd(""..diff_window_width.."vsplit term://"..git_repo_root.."/tig")
    current_view_window = vim.fn.win_getid(vim.fn.winnr())
    vim.cmd("normal h")
    vim.cmd.stopinsert()
    viewing_log = true
  end

  local function open_terminal_window()
    close_view_window()
    local total_width = vim.api.nvim_win_get_width(0)
    local diff_window_width = total_width - main_buf_width
    vim.cmd(""..diff_window_width.."vsplit term://"..git_repo_root.."//bin/zsh")
    current_view_window = vim.fn.win_getid(vim.fn.winnr())
  end

  local function on_cursor_moved()
    if vim.fn.line('.') == 1 then
      view_log()
    else
      view_diff_for_current_file()
    end
  end

  local function init()
    local status = gitato.get_status(diff_branch)
    if status == nil then
      print("ERROR: Is this a git repo?")
      return
    end

    vim.cmd("-tabnew")
    main_buf_height = vim.api.nvim_win_get_height(0)

    local tmp_buf = vim.fn.bufnr("%")
    vim.cmd("b "..main_buf)
    vim.cmd("silent bwipe! "..tmp_buf)
    vim.cmd("set syntax=gitcommit")
    vim.bo.bufhidden = "wipe"

    for _,line in ipairs(status) do
      if #line > main_buf_width then
        main_buf_width = #line
      end
    end

    for _,line in ipairs(viewer_help) do
      if #line > main_buf_width then
        main_buf_width = #line
      end
    end

    -- add some padding and account for line numbers
    main_buf_width = main_buf_width + extra_width_in_main_view
    draw_status(status)
  end

  local function keymap(key, action, callback)
    vim.api.nvim_buf_set_keymap(main_buf, 'n', key, action, {
      nowait=true,
      callback=callback
    })
  end

  local function set_file_staged(file)
    git_cmd("add -- "..file)
  end

  local function set_file_unstaged(file)
    git_cmd("reset -- "..file)
  end

  local function toggle_file_with_status_staged(file, status)
    if (status and status:sub(2,2) == "M") or status == "??" then
      set_file_staged(file)
      print("added!")
    else
      set_file_unstaged(file)
      print("reset!")
    end
  end

  -- save every file and kick off the process
  vim.cmd("wall")
  init()

  -- set up some keymaps
  keymap('q', ':tabclose!<cr>')
  keymap('<cr>', 'll')
  keymap('gn', 'llgnhh')
  keymap('gp', 'llgphh')
  keymap('l', 'llgnhh')
  keymap('h', 'llgphh')
  keymap('a', '', function()
    local status, file = get_status_and_file_from_current_line()
    if file == nil then
      return
    end
    toggle_file_with_status_staged(file, status)
    get_and_draw_status()
  end)
  keymap('R', '', function()
    local status, file = get_status_and_file_from_current_line()
    if file == nil then
      return
    end

    if (status and status:sub(2,2) == "M") then
      git_cmd("checkout -- "..file)
      print("restored!")
    else
      print("not sure what to do with status '"..status.."'")
    end
    get_and_draw_status()
  end)
  keymap('d', '', function()
    local status, file = get_status_and_file_from_current_line()
    if file then
      if status and status:sub(2,2) == "D" then
        git_cmd("rm "..file)
        print("deleted!")
      elseif status and status:sub(1,1) == "D" then
        git_cmd("reset -- "..file)
        print("undeleted!")
      end
      get_and_draw_status()
    end
  end)
  keymap('c', '', function()
    close_view_window()
    gitato.commit(git_repo_root, function()
      close_view_window()
      get_and_draw_status()
    end)
  end)
  keymap('d', '', function()
    local status, file = get_status_and_file_from_current_line()

    if status == " D" then
      git_cmd("rm "..file)
    elseif status == "??" then
      local input = vim.fn.input("really delete '"..file.."'? (type yes):")
      if input ~= "yes" then
        print("you typed '"..input.."' will not deleting")
        return
      end
      shell_cmd("rm "..file)
    else
      print("not sure what to do with status '"..status.."'")
      return
    end

    get_and_draw_status()
  end)
  keymap('b', '', function()
    diff_branch = vim.fn.input({
      prompt = "git ref:",
    })
    if diff_branch == "" then
      diff_branch = nil
    end

    close_view_window()
    get_and_draw_status()
  end)
  keymap('A', '', function()
    -- stage all that are unstaged
    local none_were_staged = true
    gitato.status_foreach(diff_branch, function(status, file)
      if status:sub(2,2) == "M" or status == "??" then
        none_were_staged = false
        set_file_staged(file)
      end
    end)

    -- Make it work like a toggle, unstage all, if none were staged
    if none_were_staged then
      gitato.status_foreach(diff_branch, function(status, file)
        if status:sub(1,1) == "M" or status:sub(1,1) == "A" then
          set_file_unstaged(file)
        end
      end)
    end

    get_and_draw_status()
  end)
  keymap('.', "", function()
    open_terminal_window()
  end)

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = main_buf,
    group = group,
    callback = function()
      vim.defer_fn(function()
        if vim.fn.bufnr() ~= main_buf then
          -- this was a move *out* of the man buf!
          return
        end
        on_cursor_moved()
      end, 0)
    end
  })

  -- clean up when we leave the main buffer
  vim.api.nvim_create_autocmd("BufUnload", {
    buffer = main_buf,
    group = group,
    callback = function()
      gitato.diff_off()
      vim.api.nvim_del_augroup_by_name(group)
    end
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "ShellCommandHappened",
    group = group,
    callback = function()
      vim.defer_fn(function()
        get_and_draw_status()
      end, 0)
    end
  })
end

return gitato
