--[[ TODOS:
- make the buffer immutable
- look into making this work on all new buffers instead of requiring an explicit fn
- consider making it a bit prettier... (filetype + highlighting)
]]
local current_dir = require "current_dir"
local telescope = require "telescope.builtin"
local gitato = require "gitato"

local newb = {}

local function updir(dir, chdir)
  local newdir = vim.fn.fnamemodify(dir, ":p:h:h")
  newdir = vim.fn.fnamemodify(newdir, ":~")
  print(newdir)
  chdir(newdir)
end


local function find_files(root)
  telescope.find_files{cwd = root}
end

local function find_git_files(root)
  telescope.git_files{cwd = root}
end

local function live_grep(root)
  telescope.live_grep{cwd = root}
end

local function find_buffers()
  telescope.buffers{}
end

local function proj_root(dir, chdir)
  local git_root = gitato.get_repo_root(dir)
  if git_root == nil then
    print "Is this a git repo?"
    return
  end
  git_root = vim.fn.fnamemodify(git_root, ":~")
  chdir(git_root)
end

local function sync_dir(dir, chdir)
  chdir(dir)
end

local function return_to_start_dir(_, chdir, start_dir)
  chdir(start_dir)
end

local function cd_prompt(dir, chdir)
  if dir:sub(-1,-1) ~= '/' then
    dir = dir .. '/'
  end

  local new_dir = vim.fn.input({
    prompt = "cd ",
    default = dir,
    cancelreturn = nil,
    completion = "dir",
  })
  if new_dir ~= nil then
    chdir(new_dir)
  end
end

local function autojump_prompt(_, chdir)
  local autojump_input = vim.fn.input({
    prompt = "jump ",
    cancelreturn = nil,
  })

  if autojump_input == nil then
    return
  end

  local output = vim.fn.systemlist("autojump "..autojump_input)

  if #output ~= 0 then
    chdir(output[1])
  end
end

local function edit_notes(dir)
  local git_root = gitato.get_repo_root(dir)
  if not git_root then
    return
  end
  local todo_file = git_root .. "/todo.txt"
  if not vim.fn.filereadable(todo_file) then
    return
  end
  vim.cmd(("e %s"):format(todo_file))
end

local function pstree(dir)
  local pid = vim.fn.getpid()
  vim.cmd(("e term://%s///usr/bin/pstree -p %s"):format(dir, pid))
end

local new_buffer_options = {
  {key=".", cmd=":e term://$dir///bin/zsh",    desc="terminal"},
  {key="d", cmd=":Oil $dir",                   desc="directory"},
  {key="f", cmd=find_files,                    desc="search for any file"},
  {key="g", cmd=find_git_files,                desc="search for a file in git"},
  {key="b", cmd=find_buffers,                  desc="search buffers by name"},
  {key="w", cmd=edit_notes,                    desc="edit work notes"},
  {key="/", cmd=live_grep,                     desc="live grep"},
  {key="t", cmd=":exec ':e '.tempname()",      desc="edit temp file"},
  {key="r", cmd=proj_root,                     desc="move to git root"},
  {key="-", cmd=updir,                         desc="cd .."},
  {key="c", cmd=cd_prompt,                     desc="cd <dir>"},
  {key="j", cmd=autojump_prompt,               desc="autojump <dir>"},
  {key="_", cmd=return_to_start_dir,           desc="cd starting directory"},
  {key=",", cmd=sync_dir,                      desc="sync dir"},
  {key="p", cmd=pstree,                        desc="show process tree"},
  {key="B", cmd=":e term://$dir///usr/bin/btop", desc="run btop command"},
  {key="C", cmd=":e term://$dir///bin/claude", desc="run claude command"},
  {key="q", cmd=":q!",                         desc="quit"},
}

function newb.create(split_command)
  return function()
    -- the directory starts with buffer *before* the split command
    local starting_dir = current_dir()
    local dir = starting_dir

    -- remove trailing "/"
    if dir:sub(-1,-1) == "/" then
      dir = dir:sub(1,-2)
    end

    if split_command ~= nil then
      vim.cmd(split_command)
    end

    local starting_buf = vim.fn.bufnr("%")
    local buf = vim.api.nvim_create_buf(false, true)
    vim.cmd("b "..buf)
    vim.bo.bufhidden = "wipe"

    local instructions = {}

    local function chdir(newdir)
      dir = newdir
      vim.cmd.chdir(newdir)
    end

    local function render()
      local lines = {dir}
      for _, val in pairs(instructions) do
        table.insert(lines, val)
      end
      -- set the contents to the instructions
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end

    local function setup()
      -- set up the key bindings and collect the instructions
      vim.api.nvim_buf_set_keymap(buf, "n", "u", "",  {
        callback = function()
          print("use '-' key instead!")
        end
      })
      vim.api.nvim_buf_set_keymap(buf, "n", "<bs>", "",  {
        callback = function()
          vim.cmd[[ exec "normal \<c-o>" ]]
        end
      })
      for _,val in ipairs(new_buffer_options) do
        if type(val.cmd) == 'function' then
          vim.api.nvim_buf_set_keymap(buf, "n", val.key, "",  {
            nowait=true,
            callback=function()
              local dir_before = dir
              val.cmd(dir, chdir, starting_dir)
              if dir_before ~= dir then
                render()
              end
            end
          })
        else
          vim.api.nvim_buf_set_keymap(buf, "n", val.key, "", {
            nowait=true,
            callback = function()
              local cmd = string.gsub(val.cmd, "$dir", dir)
              print(cmd)
              vim.cmd(cmd)
            end
          })
        end
        table.insert(instructions, val.key.." -> "..val.desc)
      end
    end

    setup()
    render()

    -- clean up the old buffer, unless it was a named file
    if vim.fn.bufname(tonumber(starting_buf)) == ""
    and vim.api.nvim_buf_is_loaded(starting_buf)
    then
      vim.cmd("silent bwipe! "..starting_buf)
    end
  end
end

return newb
