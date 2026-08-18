local OPS_REPOS = {
  { workspace = "pointo-india", repo = "ops-api" },
  { workspace = "pointo-india", repo = "ops-web" },
}

return {
  "emrearmagan/atlas.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- optional but recommended
    "MeanderingProgrammer/render-markdown.nvim", -- optional but recommended
    "esmuellert/codediff.nvim", -- optional (PullRequest diff)
    "sindrets/diffview.nvim", -- optional; or "dlyongemallo/diffview-plus.nvim"
  },
  keys = {
    { "<leader>ap", "<cmd>AtlasPulls bitbucket<cr>", desc = "Atlas: Pull Requests" },
  },
  opts = {
    pulls = {
      providers = {
        ---@type AtlasBitbucketConfig
        bitbucket = {
          user = vim.env.BITBUCKET_USER,
          token = vim.env.BITBUCKET_TOKEN,
          views = {
            {
              layout = "plain",
              repos = OPS_REPOS,
            },
          },
        },
      },
    },
  },
}
