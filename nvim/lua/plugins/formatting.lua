return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      sql = { "prettier" },
    },
    -- optional: disable biome if conform auto-detects it
    formatters = {
      biome = { command = false },
    },
  },
}
