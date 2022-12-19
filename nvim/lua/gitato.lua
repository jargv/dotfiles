local gitato = {}
local group = "gitato.autogroup"

vim.api.nvim_create_augroup(group, {clear=true})

local current_diff_buffer = nil

function gitato.diff_off()
  vim.cmd("diffoff!")
  if current_diff_buffer ~= nil
    and vim.api.nvim_buf_is_valid(current_diff_buffer) then
    vim.cmd("bwipe! "..current_diff_buffer)
  end
  current_diff_buffer = nil
end

function gitato.get_repo_root()
  local result = vim.fn.systemlist("git rev-parse --show-toplevel")
  local error = vim.api.nvim_get_vvar("shell_error")
  if error ~= 0 or #result == 0 then
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

  local current_buffer = vim.fn.bufnr("%")
  local file = vim.fn.expand("%")
  if file:sub(1, #git_root) == git_root then
    file = file:sub(#git_root + 2)
  else
    file = "./"..file
  end

  local diff_contents = vim.fn.systemlist({"git", "show", ref..':'..file})
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

function gitato.open_viewer()
  local main_buf = vim.api.nvim_create_buf(false, true)
  local main_buf_width = 0
  local current_file = nil
  local current_file_window = nil

  local function get_status()
    local result = vim.fn.systemlist({"git", "status", "-sb"})
    local error = vim.api.nvim_get_vvar("shell_error")
    if error ~= 0 then
      print(table.concat(output, "\n"))
      return nil
    end
    return result
  end

  local function draw_status(status)
    vim.api.nvim_buf_set_lines(main_buf, 0, -1, false, status)
  end

  local function get_and_draw_status()
    local status = get_status()
    if status ~= nil then
      draw_status(status)
    end
  end

  local function view_diff_for_current_line()
    local line = vim.fn.getline('.')

    -- skip comment lines
    if string.match(line, "^#") then
      return
    end

    -- grab the file and status from the line
    local status, file = string.match(line, "^%s*(%S*)%s*(%S*)$")

    -- skip empty files
    if file == "" or file == nil then
      return
    end

    -- this is the previously viewed file, no work to do
    if file == current_file then
      return
    end

    current_file = file
    if current_file_window == nil
    or not vim.api.nvim_win_is_valid(current_file_window)
    then
      -- create the window
      local total_width = vim.api.nvim_win_get_width(0)
      local diff_window_width = total_width - main_buf_width
      vim.cmd(""..diff_window_width.."vsplit "..file)
      gitato.diff_off()
      if status ~= "??" then
        gitato.toggle_diff_against_git_ref("HEAD")
      end
      vim.cmd("normal gg")
      current_file_window = vim.fn.win_getid(vim.fn.winnr())
    else
      -- or just move into the window
      vim.cmd("normal ll")
      vim.cmd("edit "..file)
      gitato.diff_off()
      if status ~= "??" then
        gitato.toggle_diff_against_git_ref("HEAD")
      end
    end
    vim.cmd("normal gg")
    vim.cmd("normal hh")
    vim.wo.winfixwidth = true
  end

  local function init()
    local status = get_status()
    if status == nil then
      print("ERROR: Is this a git repo?")
      return
    end

    vim.cmd("-tabnew")

    local tmp_buf = vim.fn.bufnr("%")
    vim.cmd("b "..main_buf)
    vim.cmd("silent bwipe! "..tmp_buf)
    vim.bo.bufhidden = "wipe"

    for _,line in ipairs(status) do
      if #line > main_buf_width then
        main_buf_width = #line
      end
    end

    -- add some padding and account for line numbers
    main_buf_width = main_buf_width + 10
    draw_status(status)
  end

  vim.cmd("wall")
  init()

  -- set up some keymaps
  local function key(key, action, callback)
    vim.api.nvim_buf_set_keymap(main_buf, 'n', key, action, {
      nowait=true,
      callback=callback
    })
  end

  key('q', ':tabclose!<cr>')
  key('<cr>', 'll')
  key('gn', 'llgnhh')
  key('gp', 'llgphh')
  key('l', 'llgnhh')
  key('h', 'llgphh')
  key('a', '', function()
    if current_file then
      vim.fn.system("git add "..current_file)
      get_and_draw_status()
      print("added!")
    end
  end)

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = main_buf,
    group = group,
    callback = view_diff_for_current_line
  })

  -- clean up when we leave the main buffer
  vim.api.nvim_create_autocmd("BufUnload", {
    buffer = main_buf,
    group = group,
    callback = function() gitato.diff_off() end
  })
end

return gitato
