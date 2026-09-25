-- ===============================
-- COLORSCHEME CONFIGURATION
-- ===============================

return {
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    priority = 1000,
    opts = {
      style = "dark",
      transparent = true,
      term_colors = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
