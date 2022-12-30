--[[ TODOS:
- look into making this work on all new buffers instead of requiring a fn
]]

local newb = {}

local new_buffer_options = {
  {key=".", cmd=":e term:///bin/zsh<cr>",     desc="start a terminal"},
  {key="d", cmd=":Explore<cr>",               desc="open a directory"},
  {key="o", cmd=":FZF --inline-info<cr>",     desc="search for a file"},
  {key="i", cmd=":Buffers<cr>",               desc="search buffers by name"},
  {key="h", cmd=":e term://tig<cr>",          desc="git history (tig)"},
  {key="q", cmd=":q!<cr>",                    desc="quit"},
}

function newb.create(split_command)
  return function()
    if split_command ~= nil then
      vim.cmd(split_command)
    end

    local starting_buf = vim.fn.bufnr("%")
    local buf = vim.api.nvim_create_buf(false, true)
    vim.cmd("b "..buf)
    vim.bo.bufhidden = "wipe"

    -- set up the key bindings and collect the instructions
    local instructions = {}
    for _,val in ipairs(new_buffer_options) do
      vim.api.nvim_buf_set_keymap(buf, "n", val.key, val.cmd, {nowait=true})
      table.insert(instructions, val.key.." -> "..val.desc)
    end

    -- set the contents to the instructions
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, instructions)

    -- clean up the old buffer, unless it was a named file
    if
      vim.fn.bufname(tonumber(starting_buf)) == "" and
      vim.api.nvim_buf_is_loaded(starting_buf) then
      vim.cmd("silent bwipe! "..starting_buf)
    end
  end
end
return newb
