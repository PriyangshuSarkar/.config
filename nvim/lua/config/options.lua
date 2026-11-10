-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Format on save for every filetype (toggle with <leader>uf / <leader>uF)
vim.g.autoformat = true

-- Remote-plugin provider hosts (python lives in a venv: brew python is PEP 668-managed)
vim.g.python3_host_prog = vim.fn.stdpath("data") .. "/python-host/bin/python"

-- gem's bin dir isn't on PATH, so ask gem for it (async to keep startup fast)
pcall(vim.system, { "gem", "environment", "gemdir" }, { text = true }, vim.schedule_wrap(function(result)
  if result.code == 0 then
    vim.g.ruby_host_prog = vim.trim(result.stdout) .. "/bin/neovim-ruby-host"
  end
end))
