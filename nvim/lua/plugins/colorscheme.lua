-- ===============================
-- COLORSCHEME CONFIGURATION
-- ===============================

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      background = { -- :h background
        light = "frappe",
        dark = "mocha",
      },
      transparent_background = true,
      term_colors = true,
      float = {
        transparent = false,
        solid = false,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-nvim",
    },
  },
}
