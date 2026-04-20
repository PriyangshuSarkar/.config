return {
  "nvim-mini/mini.icons",
  lazy = true,
  opts = {
    extension = {
      -- ✅ NestJS specific
      ["module.ts"] = { glyph = "", hl = "MiniIconsRed" },
      ["controller.ts"] = { glyph = "", hl = "MiniIconsBlue" },
      ["service.ts"] = { glyph = "", hl = "MiniIconsYellow" },
      ["guard.ts"] = { glyph = "", hl = "MiniIconsGreen" },
      ["filter.ts"] = { glyph = "", hl = "MiniIconsOrange" },
      ["pipe.ts"] = { glyph = "", hl = "MiniIconsTeal" },
      ["interceptor.ts"] = { glyph = "", hl = "MiniIconsCyan" },
      ["decorator.ts"] = { glyph = "", hl = "MiniIconsPurple" },
      ["entity.ts"] = { glyph = "", hl = "MiniIconsPink" },
      ["test.ts"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
      ["spec.ts"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
    },
  },

  init = function()
    package.preload["nvim-web-devicons"] = function()
      require("mini.icons").mock_nvim_web_devicons()
      return package.loaded["nvim-web-devicons"]
    end
  end,
}
