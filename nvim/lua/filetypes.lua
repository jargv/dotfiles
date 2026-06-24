-- Filetype detection, migrated from ftdetect/*.vim
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
    scala = "scala",
    sls = "yaml",
    ts = "typescript",
    tsx = "typescript",
    txt = "text",
    -- c / cpp
    c = "c",
    h = "c",
    cpp = "cpp",
    hpp = "cpp",
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
