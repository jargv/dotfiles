--[[
TODOS:
  - Ability to long against commit before instead of current file (maybe both?)
  - Add a hotkey to open the viewer from a diff, using the current log line as rev
  - recompute gitato view width when status changes
  - Fix bug when status is longer than the window (rare)
  - Completion help when changing diff_branch
  - hotkeys work with tig view
  - if not in a git repo, fallback to the cwd and check again
  - make it work with symlinks
consider:
  - key for refreshing status (r)
  - clean up the viewer code by using win_execute function
  - set the filetype of the diff buffer to match the source buffer
  - move the cursor along with the file when the status updates
]]
local current_dir = require("current_dir")
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
  "## . - open terminal in the repo root",
  "## c - commit",
  "## f - commit --amend",
  "## p - git pushup",
  "## P - git pushupforce",
  "## q - quit"
}

local unsupported_diff_extensions = {
  ".aseprite", ".png", ".spl", ".wav", ".mp3"
}

local function file_diff_not_supported(name)
  for _, ext in ipairs(unsupported_diff_extensions) do
    if name:sub(-#ext) == ext then
      return true
    end
  end
  return false
end

local not_a_repo_error_msg = "ERROR: Is this a git repo?"

local current_diff_buffer = nil
local current_diff_log_buffer = nil
local on_move_log_cursor = function(_amount) end
gitato.move_log_cursor = function(amount)
  on_move_log_cursor(amount)
end

local on_toggle_diff_log_width = function() end
gitato.toggle_diff_log_width = function()
  on_toggle_diff_log_width()
end

function gitato.diff_off()
  vim.cmd("diffoff!")
  if current_diff_buffer ~= nil
  and vim.api.nvim_buf_is_valid(current_diff_buffer) then
    vim.cmd("bwipe! "..current_diff_buffer)
  end
  if current_diff_log_buffer ~= nil
  and vim.api.nvim_buf_is_valid(current_diff_log_buffer) then
    vim.cmd("bwipe! "..current_diff_log_buffer)
  end
  current_diff_buffer = nil
  current_diff_log_buffer = nil
end

function gitato.get_repo_root(dir)
  local first_dir
  if dir ~= nil then
    first_dir = dir
  else
    first_dir = vim.fn.expand("%:p") -- from current file
  end

  local current = current_dir()
  local dirs_to_try = {
    first_dir,
    vim.fn.fnamemodify(vim.fn.resolve(first_dir), ":h"),
    current,
    vim.fn.fnamemodify(vim.fn.resolve(current), ":h"),
  }

  local repo_root = nil
  for _,dir in ipairs(dirs_to_try) do
    if dir == nil then
      goto continue
    end

    print("dir => ", dir)
    local result = vim.fn.systemlist("cd "..dir.." && git rev-parse --show-toplevel")
    print("result => ", result)
    local error = vim.api.nvim_get_vvar("shell_error")
    print("error => ", error)
    if error == 0 and #result ~= 0 then
      repo_root = result[1]
      break
    end

    ::continue::
  end

  if repo_root == nil then
    return nil
  end

  if repo_root:sub(-1,-1) ~= "/" then
    repo_root = repo_root .. "/"
  end

  return repo_root
end

function gitato.toggle_diff_against_git_ref(ref)
  if current_diff_buffer ~= nil then
    gitato.diff_off()
    return
  end

  local git_root = gitato.get_repo_root()
  if git_root == nil then
    print(not_a_repo_error_msg)
    return
  end

  local file = vim.fn.resolve(vim.fn.expand("%:p"))
  if file:sub(1, #git_root) == git_root then
    file = file:sub(#git_root + 1)
  else
    file = "./"..file
  end

  -- get the log contents
  local log_contents = vim.fn.systemlist("cd "..git_root.." && git log --oneline ".. file)
  local err = vim.api.nvim_get_vvar("shell_error")
  if err ~= 0 then
    print(table.concat(log_contents, "\n"))
    print(not_a_repo_error_msg)
    error()
  end

  local log_cursor_line = 1
  local diff_against = ref == nil and "HEAD" or ref
  local doing_log = ref == nil

  if doing_log then
    -- set up the log window
    vim.cmd("0vnew")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.opt.wrap = false
    current_diff_log_buffer = vim.fn.bufnr("%")
    vim.cmd("normal h")
  end

  -- set up the diff window
  vim.cmd("leftabove vnew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  current_diff_buffer = vim.fn.bufnr("%")
  vim.cmd(":diffthis")
  vim.cmd("normal l")
  vim.cmd(":diffthis")

  local log_style = "none"
  local function draw_log_buffer()
    if not doing_log then
      return
    end
    local max_length = 0
    local log_lines = {
      log_cursor_line == 1 and "> HEAD" or "  HEAD"
    }
    for i, contents in ipairs(log_contents) do
      local line_number = i + 1
      if #contents > max_length then
        max_length = #contents
      end
      local indent = line_number == log_cursor_line and "> " or "  "
      table.insert(log_lines, indent..contents)
    end

    if log_style == "slim" then
      max_length = 12
    elseif log_style == "none" then
      max_length = 0
    end

    vim.api.nvim_buf_set_lines(current_diff_log_buffer, 0, -1, false, log_lines)
    vim.api.nvim_win_set_width(vim.fn.win_findbuf(current_diff_log_buffer)[1], max_length)
  end

  local function load_diff_contents()
    local diff_contents = vim.fn.systemlist("cd "..git_root.." && git show ".. diff_against..':'..file)
    local err = vim.api.nvim_get_vvar("shell_error")
    if err ~= 0 then
      print(table.concat(diff_contents, "\n"))
      error(not_a_repo_error_msg)
    end
    vim.api.nvim_buf_set_lines(current_diff_buffer, 0, -1, false, diff_contents)
    vim.fn.win_execute(vim.fn.win_findbuf(current_diff_buffer)[1], "diffu")
  end

  draw_log_buffer()
  load_diff_contents()

  local function update_log_cursor(line)
    log_cursor_line = line
    if log_cursor_line < 1 then
      log_cursor_line = 1
    end
    draw_log_buffer()
    if log_cursor_line == 1 then
      diff_against = "HEAD"
    else
      local contents = log_contents[log_cursor_line]
      local words = vim.fn.split(contents, " ")
      diff_against = words[1]
    end
    load_diff_contents()
  end

  on_move_log_cursor = function(amount)
    if current_diff_buffer == nil
    or not vim.api.nvim_buf_is_valid(current_diff_buffer)
    then
      return
    end
    update_log_cursor(log_cursor_line + amount)
  end

  on_toggle_diff_log_width = function()
    if current_diff_buffer == nil
    or not vim.api.nvim_buf_is_valid(current_diff_buffer)
    then
      return
    end
    if log_style == "none" then
      log_style = "wide"
    elseif log_style == "wide" then
      log_style = "slim"
    elseif log_style == "slim" then
      log_style = "none"
    end
    draw_log_buffer()
  end

  if doing_log then
    vim.api.nvim_buf_set_keymap(current_diff_log_buffer, 'n', '<cr>', "", {
      nowait=true,
      callback=function()
        local line = vim.fn.line('.')
        update_log_cursor(line)
      end
    })
  end

end

local function parse_status_line(line)
  local status, file = string.match(line, "^(..)%s*(%S*)$")
  return status, file
end

local function shell_cmd(cmd, root)
  root = root or gitato.get_repo_root()
  local result = vim.fn.systemlist(("cd %s && %s"):format(root, cmd))
  if 0 ~= vim.api.nvim_get_vvar("shell_error") then
    print(table.concat(result, '\n'))
    return nil
  end
  return result
end

local function git_cmd(c, root)
  return shell_cmd("git "..c, root)
end

function gitato.get_status(diff_branch, repo_root)
  if diff_branch ~= nil then
    return git_cmd(("diff --name-status %s"):format(diff_branch), repo_root)
  end

  return git_cmd("status -sb", repo_root)
end


function gitato.status_foreach(diff_branch, cb, repo_root)
  local status_lines = gitato.get_status(diff_branch, repo_root)
  if status_lines == nil then
    print(not_a_repo_error_msg)
    return
  end

  for _,line in ipairs(status_lines) do
    local status, file = parse_status_line(line)
    if status ~= nil and status ~= "##" and file ~= nil then
      cb(status, file)
    end
  end
end

function gitato.commit(repo_root, post_commit, amend)
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

  -- if we're doing an ammend, but the previous commit message in there
  if amend then
    -- first get the git status
    local last_message = vim.fn.systemlist(
    ("cd %s && git log -1 --pretty='%%B'"):format(repo_root)
    )
    if 0 ~= vim.api.nvim_get_vvar("shell_error") then
      print("error getting last commit message...")
      return
    end
    vim.api.nvim_buf_set_lines(buffer, 0, 0, false, {last_message[1]})
  end

  -- commit when the buffer is written
  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = buffer,
    callback = function()
      local ammend_str = amend and " --amend " or ""
      local cmd = ("cd %s && git commit %s --cleanup=strip --file=%s"):format(
        repo_root, ammend_str, file_name
      )
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
    print(not_a_repo_error_msg)
    return
  end

  local main_buf = vim.api.nvim_create_buf(false, true)
  local main_window
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
    local status = gitato.get_status(diff_branch, git_repo_root)

    if status == nil then
      return
    end

    main_buf_width = 0
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
    vim.api.nvim_win_set_width(main_window, main_buf_width)
    draw_status(status)
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

    if file == nil or file == "" or file_diff_not_supported(file) then
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

    -- no diff on deleted files
    if status == " D" or status == "D " then
      return
    end

    -- close the current diff window before opening another
    close_view_window()

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

  local function open_terminal_window(input)
    close_view_window()
    local total_width = vim.api.nvim_win_get_width(0)
    local diff_window_width = total_width - main_buf_width
    vim.cmd(""..diff_window_width.."vsplit term://"..git_repo_root.."//bin/zsh")
    current_view_window = vim.fn.win_getid(vim.fn.winnr())
    if input then
      vim.api.nvim_feedkeys(input, "i", false);
    end
  end

  local function on_cursor_moved()
    if vim.fn.line('.') == 1 then
      view_log()
    else
      view_diff_for_current_file()
    end
  end

  local function init()
    vim.cmd("-tabnew")
    vim.t.tabname = "gitato"
    main_buf_height = vim.api.nvim_win_get_height(0)

    local tmp_buf = vim.fn.bufnr("%")
    vim.cmd("b "..main_buf)
    vim.cmd("silent bwipe! "..tmp_buf)
    vim.cmd("set syntax=gitcommit")
    vim.bo.bufhidden = "wipe"

    main_window = vim.api.nvim_get_current_win()

    get_and_draw_status()
  end

  local function keymap(key, action, callback)
    vim.api.nvim_buf_set_keymap(main_buf, 'n', key, action, {
      nowait=true,
      callback=callback
    })
  end

  local function set_file_staged(file)
    git_cmd("add -- "..file, git_repo_root)
  end

  local function set_file_unstaged(file)
    git_cmd("reset -- "..file, git_repo_root)
  end

  local function set_file_deleted(file)
    git_cmd("rm "..file, git_repo_root)
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

    if
      status and (
        status:sub(2,2) == "M" or
        status:sub(2,2) == "D"
      )
    then
      git_cmd("checkout -- "..file, git_repo_root)
      print("restored!")
    else
      print("not sure what to do with status '"..status.."'")
    end
    get_and_draw_status()
  end)
  keymap('c', '', function()
    close_view_window()
    gitato.commit(git_repo_root, function()
      close_view_window()
      get_and_draw_status()
    end)
  end)
  keymap('f', '', function()
    close_view_window()
    gitato.commit(git_repo_root, function()
      close_view_window()
      get_and_draw_status()
    end, true)
  end)
  keymap('D', '', function()
    -- Not mapped to anything, but I keep doing it an accident :D
  end)
  keymap('d', '', function()
    local status, file = get_status_and_file_from_current_line()

    if status == " D" then
      set_file_deleted(file)
    elseif status == "D " then
      set_file_unstaged(file)
    elseif status == "??" then
      local input = vim.fn.input("really delete untracked filed '"..file.."'? (type yes):")
      if input ~= "yes" then
        print("you typed '"..input.."' will not deleting")
        return
      end
      shell_cmd("rm "..file, git_repo_root)
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
      elseif status:sub(2) == "D" then
        set_file_deleted(file)
      end
    end, git_repo_root)

    -- Make it work like a toggle, unstage all, if none were staged
    if none_were_staged then
      gitato.status_foreach(diff_branch, function(status, file)
        if status:sub(1,1) == "M" or status:sub(1,1) == "A" then
          set_file_unstaged(file)
        end
      end, git_repo_root)
    end

    get_and_draw_status()
  end)
  keymap('.', "", function()
    open_terminal_window()
  end)
  keymap('p', "", function ()
    open_terminal_window("git pushup")
  end)
  keymap('P', "", function ()
    open_terminal_window("git pushupforce")
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
