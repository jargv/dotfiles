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
  local output = vim.fn.systemlist({"git", "status", "-sb"})
  local error = vim.api.nvim_get_vvar("shell_error")
  if error ~= 0 then
    print(table.concat(output, "\n"))
    print("ERROR: Is this a git repo?")
    return
  end

  local main_buf = vim.api.nvim_create_buf(false, true)

  vim.cmd("-tabnew")
  local tmp_buf = vim.fn.bufnr("%")
  vim.cmd("b "..main_buf)
  vim.cmd("silent bwipe! "..tmp_buf)
  vim.bo.bufhidden = "wipe"

  vim.api.nvim_buf_set_lines(main_buf, -1, -1, false, output)

  local menu_width = 0
  for _,line in ipairs(output) do
    if #line > menu_width then
      menu_width = #line
    end
  end

  local current_file = nil
  local current_file_window = nil

  -- add some padding and account for line numbers
  menu_width = menu_width + 10

  -- set up some keymaps
  vim.api.nvim_buf_set_keymap(main_buf, 'n', 'q', ':tabclose!<cr>', {nowait=true})
  vim.api.nvim_buf_set_keymap(main_buf, 'n', '<cr>', 'll', {nowait=true})
  vim.api.nvim_buf_set_keymap(main_buf, 'n', 'gn', 'llgnhh', {nowait=true})
  vim.api.nvim_buf_set_keymap(main_buf, 'n', 'gp', 'llgphh', {nowait=true})
  vim.api.nvim_buf_set_keymap(main_buf, 'n', 'l', 'llgnhh', {nowait=true})
  vim.api.nvim_buf_set_keymap(main_buf, 'n', 'h', 'llgphh', {nowait=true})

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = main_buf,
    group = group,
    callback = function()
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

      -- view the file if we've moved to a new one
      if file ~= current_file then
        current_file = file
        if current_file_window == nil
        or not vim.api.nvim_win_is_valid(current_file_window)
        then
          -- create the window
          local total_width = vim.api.nvim_win_get_width(0)
          local diff_window_width = total_width - menu_width
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
    end
  })

  -- clean up when we leave the main buffer
  vim.api.nvim_create_autocmd("BufUnload", {
    buffer = main_buf,
    group = group,
    callback = function() gitato.diff_off() end
  })
end

return gitato
