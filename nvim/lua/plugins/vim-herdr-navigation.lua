return {
  "paulbkim-dev/vim-herdr-navigation",
  cond = vim.env.HERDR_ENV == "1",
  keys = { "<c-h>", "<c-j>", "<c-k>", "<c-l>" },
  config = function(plugin)
    dofile(plugin.dir .. "/editor/nvim.lua")
  end,
}
