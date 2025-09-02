return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    tag = "v1.10.0",
    config = function()
      require("catppuccin").setup({
        flavour = "auto", -- latte, frappe, macchiato, mocha
        background = { -- :h background
          light = "frappe",
          dark = "mocha",
        },
        transparent_background = true, -- disables setting the background color.
        float = {
          transparent = false, -- enable transparent floating windows
          solid = true, -- use solid styling for floating windows, see |winborder|
        },
        -- show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        -- term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
        -- dim_inactive = {
        --   enabled = false, -- dims the background color of inactive window
        --   shade = "dark",
        --   percentage = 0.15, -- percentage of the shade to apply to the inactive window
        -- },
        -- no_italic = false, -- Force no italic
        -- no_bold = false, -- Force no bold
        -- no_underline = false, -- Force no underline
        -- styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        --   comments = { "italic" },
        --   conditionals = { "italic" },
        --   loops = {},
        --   functions = {},
        --   keywords = {},
        --   strings = {},
        --   variables = {},
        --   numbers = {},
        --   booleans = {},
        --   properties = {},
        --   types = {},
        --   operators = {},
        -- },
        -- color_overrides = {},
        -- custom_highlights = {},
        -- default_integrations = true,
        -- auto_integrations = false,
        -- integrations = {
        --   cmp = true,
        --   gitsigns = true,
        --   nvimtree = true,
        --   treesitter = true,
        --   notify = false,
        --   mini = {
        --     enabled = true,
        --     indentscope_color = "",
        --   },
        -- },
      })

      -- set colorscheme after setup
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
