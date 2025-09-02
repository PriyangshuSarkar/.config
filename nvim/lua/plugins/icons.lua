return {
  "echasnovski/mini.icons",
  lazy = true,
  opts = {
    file = {
      [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
      ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      ["docker-compose.yml"] = { glyph = "󰡨", hl = "MiniIconsBlue" },
      ["package.json"] = { glyph = "󰎙", hl = "MiniIconsGreen" },
      ["package-lock.json"] = { glyph = "", hl = "MiniIconsOrange" },
      ["bun.lock"] = { glyph = "", hl = "MiniIconsWhite" },
      ["bun.lockb"] = { glyph = "", hl = "MiniIconsWhite" },
      ["tsconfig.json"] = { glyph = "", hl = "MiniIconsBlue" },
      ["main.ts"] = { glyph = "", hl = "MiniIconsRed" },
      ["README.md"] = { glyph = "", hl = "MiniIconsBlue" },
      ["LICENSE"] = { glyph = "", hl = "MiniIconsYellow" },
      -- Added
      [".env.example"] = { glyph = "", hl = "MiniIconsYellow" },
      ["tailwind.config.js"] = { glyph = "󱏿", hl = "MiniIconsCyan" },
      ["tailwind.config.ts"] = { glyph = "󱏿", hl = "MiniIconsCyan" },
      ["vite.config.js"] = { glyph = "󰉁", hl = "MiniIconsOrange" },
      ["vite.config.ts"] = { glyph = "󰉁", hl = "MiniIconsOrange" },
      ["ormconfig.json"] = { glyph = "", hl = "MiniIconsYellow" },
      ["ormconfig.js"] = { glyph = "", hl = "MiniIconsYellow" },
      ["ormconfig.ts"] = { glyph = "", hl = "MiniIconsYellow" },
      ["nest-cli.json"] = { glyph = "", hl = "MiniIconsRed" },
      ["Procfile"] = { glyph = "󰆍", hl = "MiniIconsPurple" },
      ["bitbucket-pipelines.yml"] = { glyph = "", hl = "MiniIconsBlue" },
      ["aws.yml"] = { glyph = "󰸏", hl = "MiniIconsOrange" },
      ["aws.json"] = { glyph = "󰸏", hl = "MiniIconsOrange" },
    },

    filetype = {
      dotenv = { glyph = "", hl = "MiniIconsYellow" },
      markdown = { glyph = "", hl = "MiniIconsBlue" },
      yaml = { glyph = "", hl = "MiniIconsOrange" },
      json = { glyph = "", hl = "MiniIconsYellow" },
      dockerfile = { glyph = "󰡨", hl = "MiniIconsBlue" },
      javascript = { glyph = "", hl = "MiniIconsYellow" },
      typescript = { glyph = "", hl = "MiniIconsBlue" },
      html = { glyph = "", hl = "MiniIconsOrange" },
      css = { glyph = "", hl = "MiniIconsBlue" },
      scss = { glyph = "", hl = "MiniIconsPink" },
      python = { glyph = "", hl = "MiniIconsYellow" },
      go = { glyph = "", hl = "MiniIconsCyan" },
      rust = { glyph = "", hl = "MiniIconsOrange" },
      java = { glyph = "", hl = "MiniIconsRed" },
      sh = { glyph = "", hl = "MiniIconsGreen" },
      lua = { glyph = "", hl = "MiniIconsBlue" },
      toml = { glyph = "", hl = "MiniIconsGrey" },
    },

    extension = {
      -- ✅ NestJS specific (untouched)
      ["module.ts"] = { glyph = "", hl = "MiniIconsRed" },
      ["controller.ts"] = { glyph = "", hl = "MiniIconsBlue" },
      ["service.ts"] = { glyph = "", hl = "MiniIconsYellow" },
      ["guard.ts"] = { glyph = "", hl = "MiniIconsGreen" },
      ["filter.ts"] = { glyph = "", hl = "MiniIconsOrange" },
      ["pipe.ts"] = { glyph = "", hl = "MiniIconsTeal" },
      ["interceptor.ts"] = { glyph = "", hl = "MiniIconsCyan" },
      ["decorator.ts"] = { glyph = "", hl = "MiniIconsPurple" },
      ["entity.ts"] = { glyph = "", hl = "MiniIconsPink" },
      ["dto.ts"] = { glyph = "󰞇", hl = "MiniIconsAzure" },

      -- Standard + added support
      ["jsx"] = { glyph = "", hl = "MiniIconsCyan" },
      ["tsx"] = { glyph = "", hl = "MiniIconsBlue" },
      ["d.ts"] = { glyph = "", hl = "MiniIconsTeal" },
      ["env"] = { glyph = "", hl = "MiniIconsYellow" },
      ["lock"] = { glyph = "", hl = "MiniIconsGrey" },
      ["config.js"] = { glyph = "", hl = "MiniIconsBlue" },
      ["config.ts"] = { glyph = "", hl = "MiniIconsBlue" },
      ["test.ts"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
      ["spec.ts"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
      ["md"] = { glyph = "", hl = "MiniIconsBlue" },
      ["aws"] = { glyph = "󰸏", hl = "MiniIconsOrange" },
      ["procfile"] = { glyph = "󰆍", hl = "MiniIconsPurple" },
      ["bitbucket-pipelines"] = { glyph = "", hl = "MiniIconsBlue" },

      -- More common langs
      ["py"] = { glyph = "", hl = "MiniIconsYellow" },
      ["go"] = { glyph = "", hl = "MiniIconsCyan" },
      ["rs"] = { glyph = "", hl = "MiniIconsOrange" },
      ["java"] = { glyph = "", hl = "MiniIconsRed" },
      ["sh"] = { glyph = "", hl = "MiniIconsGreen" },
      ["lua"] = { glyph = "", hl = "MiniIconsBlue" },
      ["yml"] = { glyph = "", hl = "MiniIconsOrange" },
    },

    folder = {
      default = { glyph = "", hl = "MiniIconsBlue" },
      open = { glyph = "", hl = "MiniIconsBlue" },

      src = { glyph = "󰘦", hl = "MiniIconsGreen" },
      test = { glyph = "󰙨", hl = "MiniIconsYellow" },
      spec = { glyph = "󰙨", hl = "MiniIconsYellow" },
      docs = { glyph = "", hl = "MiniIconsBlue" },
      config = { glyph = "", hl = "MiniIconsGrey" },
      scripts = { glyph = "", hl = "MiniIconsGreen" },
      build = { glyph = "", hl = "MiniIconsOrange" },
      dist = { glyph = "󰀼", hl = "MiniIconsGrey" },

      -- Tooling
      [".git"] = { glyph = "", hl = "MiniIconsRed" },
      [".github"] = { glyph = "", hl = "MiniIconsPurple" },
      [".bitbucket"] = { glyph = "", hl = "MiniIconsBlue" },
      [".aws"] = { glyph = "󰸏", hl = "MiniIconsOrange" },
      ["node_modules"] = { glyph = "", hl = "MiniIconsGreen" },
      [".vscode"] = { glyph = "", hl = "MiniIconsBlue" },
    },
  },

  init = function()
    package.preload["nvim-web-devicons"] = function()
      require("mini.icons").mock_nvim_web_devicons()
      return package.loaded["nvim-web-devicons"]
    end
  end,
}
