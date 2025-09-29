return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    config = function()
      local cb = require("diffview.config").diffview_callback
      require("diffview").setup({
        enhanced_diff_hl = true, -- nicer highlighting
      })
    end,
  },
}
