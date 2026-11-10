return {
  {
    "snacks.nvim",
    opts = {
      image = { enabled = true },
      statuscolumn = { enabled = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- parsers Snacks.image needs for inline rendering
      ensure_installed = { "latex", "scss", "svelte", "typst", "vue" },
    },
  },
}
