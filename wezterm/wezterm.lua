-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- Window settings
config.enable_tab_bar = false
config.window_decorations = "RESIZE"

-- Background blur (works on macOS and Windows with compositor support)
config.window_background_opacity = 0.75
config.macos_window_background_blur = 100

-- Initial window geometry
config.initial_cols = 120
config.initial_rows = 28

-- Font settings
config.font_size = 13
config.font = wezterm.font("JetBrains Mono")

-- Color scheme
config.color_scheme = "Catppuccin Macchiato"

-- Finally, return the configuration to wezterm:
return config
