return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true, -- show blame for the current line
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- "eol" | "overlay" | "right_align"
        delay = 500,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> • <summary>",
    },
  },
}
