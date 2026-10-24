return {
  "stevearc/conform.nvim",
  opts = {
    -- use the LSP formatter when no conform formatter is configured for a filetype
    default_format_opts = { lsp_format = "fallback" },
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
