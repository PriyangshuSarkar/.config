vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("dashboard_header_hl", { clear = true }),
  callback = function()
    -- DiagnosticOk is every colorscheme's "green/success" highlight group,
    -- so this tracks whatever theme is active instead of hardcoding one palette
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = "DiagnosticOk" })
    if ok and hl.fg then
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = hl.fg })
    end
  end,
})

return {
  {
    "snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            [[                                                                       ]],
            [[                                                                     ]],
            [[       ████ ██████           █████      ██                     ]],
            [[      ███████████             █████                             ]],
            [[      █████████ ███████████████████ ███   ███████████   ]],
            [[     █████████  ███    █████████████ █████ ██████████████   ]],
            [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
            [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
            [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
            [[                                                                       ]],
          }, "\n"),
        },
      },
    },
  },
}
