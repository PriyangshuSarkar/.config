-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ─── Copy context path for AI agents ─────────────────────────────────────────
-- <leader>cy  – copies  @relative/path/to/file#LLINE  (Claude Code format)
-- <leader>cY  – copies  @/absolute/path/to/file#LLINE
-- Also available as the Ex command  :CopyContext  or  :CopyContextAbs

-- Captured once at startup so relative paths are always anchored to the
-- directory from which Neovim was launched, regardless of later :cd changes.
local project_root = vim.fn.getcwd()

local function copy_context(mode, abs)
  local file_abs = vim.fn.expand("%:p")
  if file_abs == "" then
    vim.notify("CopyContext: buffer has no file name", vim.log.levels.WARN)
    return
  end

  local path
  if abs then
    path = file_abs
  else
    local prefix = project_root .. "/"
    if vim.startswith(file_abs, prefix) then
      path = file_abs:sub(#prefix + 1)
    else
      -- File is outside the project root; fall back to absolute path
      path = file_abs
    end
  end

  local lines
  if mode == "v" then
    -- Visual mode: use '< and '> marks (set when leaving visual mode)
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    if start_line == end_line then
      lines = "#L" .. start_line
    else
      lines = "#L" .. start_line .. "-" .. end_line
    end
  else
    -- Normal mode: current cursor line
    lines = "#L" .. vim.fn.line(".")
  end

  local text = "@" .. path .. lines

  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  vim.notify("Copied: " .. text, vim.log.levels.INFO)
end

-- Ex commands
vim.api.nvim_create_user_command("CopyContext", function(opts)
  copy_context(opts.range > 0 and "v" or "n", false)
end, { range = true, desc = "Copy relative path:line(s) to clipboard" })

vim.api.nvim_create_user_command("CopyContextAbs", function(opts)
  copy_context(opts.range > 0 and "v" or "n", true)
end, { range = true, desc = "Copy absolute path:line(s) to clipboard" })

-- Normal-mode keymaps
vim.keymap.set("n", "<leader>cy", function()
  copy_context("n", false)
end, { desc = "Copy relative context path:line" })

vim.keymap.set("n", "<leader>cY", function()
  copy_context("n", true)
end, { desc = "Copy absolute context path:line" })

-- Visual-mode keymaps  (exit first so '< '> marks are updated)
vim.keymap.set("v", "<leader>cy", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  copy_context("v", false)
end, { desc = "Copy relative context path:lines" })

vim.keymap.set("v", "<leader>cY", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  copy_context("v", true)
end, { desc = "Copy absolute context path:lines" })
