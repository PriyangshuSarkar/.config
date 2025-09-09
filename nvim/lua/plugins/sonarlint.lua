-- lua/plugins/sonarlint.lua
return {
  "schrieveslaach/sonarlint.nvim",
  url = "https://gitlab.com/schrieveslaach/sonarlint.nvim", -- 👈 required
  dependencies = {
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local mason_registry = require("mason-registry")
    local sonarlint = mason_registry.get_package("sonarlint-language-server")
    local sonarlint_path = sonarlint:get_install_path()

    require("sonarlint").setup({
      server = {
        cmd = {
          "sonarlint-language-server",
          "-stdio",
          "-analyzers",
          vim.fn.expand(sonarlint_path .. "/share/sonarlint-analyzers/sonarpython.jar"),
          vim.fn.expand(sonarlint_path .. "/share/sonarlint-analyzers/sonarcfamily.jar"),
          vim.fn.expand(sonarlint_path .. "/share/sonarlint-analyzers/sonarjava.jar"),
          vim.fn.expand(sonarlint_path .. "/share/sonarlint-analyzers/sonarjs.jar"),
        },
      },
      filetypes = { "python", "cpp", "c", "java", "javascript", "typescript" },
    })
  end,
}
