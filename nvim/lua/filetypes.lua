-- Filetype detection
-- See :help vim.filetype.add

vim.filetype.add {
  extension = {
    arg = "arg",
    clj = "clojure",
    cljs = "clojure",
    fs = "glsl",
    vs = "glsl",
    glsl = "glsl",
    go = "go",
    gradle = "groovy",
    mjs = "javascript",
    scala = "scala",
    sls = "yaml",
    ts = "typescript",
    tsx = "typescript",
    txt = "text",
    todent = "todent",
    -- c / cpp
    c = "c",
    h = "c",
    cpp = "cpp",
    hpp = "cpp",
  },
  -- Treat this exact basename as Todent rather than todo.txt format.
  filename = {
    ["todo.txt"] = "todent",
  },
  pattern = {
    [".*/journal/.*%.md"] = "journal.markdown",
  },
}

-- txtDetect.vim also turned on spell for text files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "text",
  callback = function()
    vim.opt_local.spell = true
  end,
})
