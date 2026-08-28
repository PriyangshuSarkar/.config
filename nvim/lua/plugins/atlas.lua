local BITBUCKET_WORKSPACE = "pointo-india"

---Fetch only repo names/slugs (no PR data, no other repo metadata).
---@param workspace string
---@param on_done fun(repos: { name: string, slug: string }[]|nil, err: string|nil)
local function fetch_repo_names(workspace, on_done)
  local service = require("atlas.pulls.providers.bitbucket.api.service")
  local endpoint = string.format("/repositories/%s?pagelen=100&fields=values.name,values.slug,next", workspace)

  return service.fetch_all_values(endpoint, function(result, err)
    if err then
      on_done(nil, err)
      return
    end

    local repos = {}
    for _, raw in ipairs(result.values or {}) do
      table.insert(repos, { name = tostring(raw.name or raw.slug or ""), slug = tostring(raw.slug or "") })
    end
    table.sort(repos, function(a, b)
      return a.name:lower() < b.name:lower()
    end)
    on_done(repos, nil)
  end, { action = "Fetch repository names", workspace = workspace })
end

local function select_repo_and_open_pulls()
  fetch_repo_names(BITBUCKET_WORKSPACE, function(repos, err)
    if err then
      vim.notify("Atlas: failed to fetch repositories - " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if repos == nil or #repos == 0 then
      vim.notify("Atlas: no repositories found", vim.log.levels.WARN)
      return
    end

    vim.ui.select(repos, {
      prompt = string.format("Atlas: Select repo (%s)", BITBUCKET_WORKSPACE),
      format_item = function(repo)
        return repo.name
      end,
    }, function(repo)
      if repo == nil then
        return
      end
      ---@type AtlasBitbucketViewConfig
      local view = {
        name = repo.name,
        layout = "plain",
        targets = { { workspace = BITBUCKET_WORKSPACE, repo = repo.slug } },
      }
      require("atlas").open("pulls", "bitbucket", { initial_view = view })
    end)
  end)
end

return {
  "emrearmagan/atlas.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- optional but recommended
    "MeanderingProgrammer/render-markdown.nvim", -- optional but recommended
    "esmuellert/codediff.nvim", -- optional (PullRequest diff)
    "sindrets/diffview.nvim", -- optional; or "dlyongemallo/diffview-plus.nvim"
  },
  keys = {
    { "<leader>ap", select_repo_and_open_pulls, desc = "Atlas: Pull Requests (select repo)" },
  },
  opts = {
    providers = {
      ---@type AtlasBitbucketProviderConfig
      bitbucket = {
        user = vim.env.BITBUCKET_USER,
        token = vim.env.BITBUCKET_TOKEN,
      },
    },
  },
}
