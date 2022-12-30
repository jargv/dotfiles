--[[ TODOS:
- look into making this work on all new buffers instead of requiring an explicit fn
- look into collecting a terminal's cwd and using it
]]

local newb = {}

local function updir(dir, chdir)
  local newdir = vim.fn.fnamemodify(dir, ":h")
  print(newdir)
  chdir(newdir)
end

local new_buffer_options = {
  {key=".", cmd = ":e term://$dir///bin/zsh", desc="start a terminal"},
  {key="d", cmd = ":Explore $dir",           desc="open a directory"},
  {key="o", cmd = ":FZF --inline-info $dir", desc="search for a file"},
  {key="i", cmd = ":Buffers",           desc="search buffers by name"},
  {key="h", cmd = ":e term://$dir//tig", desc="git history (tig)"},
  {key="u", cmd = updir              ,  desc="cd .."},
  {key="q", cmd = ":q!",                desc="quit"},
}

function newb.create(split_command)
  return function()
    -- the directory starts with buffer *before* the split command
    local dir = vim.fn.expand("%:p:h")

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
      for _,val in ipairs(new_buffer_options) do
        if type(val.cmd) == 'function' then
          vim.api.nvim_buf_set_keymap(buf, "n", val.key, "",  {
            nowait=true,
            callback=function()
              local dir_before = dir
              val.cmd(dir, chdir)
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
