#!/bin/bash
# ===============================
# UNIFIED THEME SWITCHER
# ===============================
# Seamlessly toggle between catppuccin and gruvbox themes across all tools
# Usage: theme-switch <catppuccin|gruvbox>
#        theme-catppuccin
#        theme-gruvbox
#        theme-current

CONFIG_DIR="${HOME}/.config"

# ===============================
# Theme definitions
# ===============================
declare -A CATPPUCCIN=(
  [nvim_colorscheme]='colorscheme = "catppuccin"'
  [nvim_disabled]='-- colorscheme = "gruvbox"'
  [tmux_source]='source-file ~/.config/tmux/themes/catppuccin.conf'
  [tmux_disabled]='# source-file ~/.config/tmux/themes/gruvbox.conf'
  [starship_export]='export STARSHIP_CONFIG=~/.config/starship/themes/catppuccin.toml'
  [starship_disabled]='# export STARSHIP_CONFIG=~/.config/starship/themes/gruvbox.toml'
  [yazi_dark]='dark = "catppuccin-mocha"'
  [yazi_light]='light = "catppuccin-mocha"'
  [bat_theme]="--theme='Catppuccin Mocha'"
  [bat_disabled]="# --theme='gruvbox-dark'"
  [ghostty_theme]='theme = Catppuccin Mocha'
  [zed_theme]='"theme": "Catppuccin Mocha"'
  [lazygit_theme]='catppuccin-mocha'
)

declare -A GRUVBOX=(
  [nvim_colorscheme]='colorscheme = "gruvbox"'
  [nvim_disabled]='-- colorscheme = "catppuccin"'
  [tmux_source]='source-file ~/.config/tmux/themes/gruvbox.conf'
  [tmux_disabled]='# source-file ~/.config/tmux/themes/catppuccin.conf'
  [starship_export]='export STARSHIP_CONFIG=~/.config/starship/themes/gruvbox.toml'
  [starship_disabled]='# export STARSHIP_CONFIG=~/.config/starship/themes/catppuccin.toml'
  [yazi_dark]='dark = "gruvbox-dark"'
  [yazi_light]='light = "gruvbox-dark"'
  [bat_theme]="--theme='gruvbox-dark'"
  [bat_disabled]="# --theme='Catppuccin Mocha'"
  [ghostty_theme]='theme = Gruvbox Dark'
  [zed_theme]='"theme": "Gruvbox Material"'
  [lazygit_theme]='gruvbox'
)

# ===============================
# Helper functions
# ===============================
_theme_detect_current() {
  # Check nvim colorscheme.lua for current theme
  # Look for uncommented colorscheme line (starts with spaces, not --)
  local nvim_file="$CONFIG_DIR/nvim/lua/plugins/colorscheme.lua"
  if grep -E '^\s+colorscheme = "gruvbox"' "$nvim_file" >/dev/null 2>&1; then
    echo "gruvbox"
  elif grep -E '^\s+colorscheme = "catppuccin"' "$nvim_file" >/dev/null 2>&1; then
    echo "catppuccin"
  else
    echo "unknown"
  fi
}

_theme_update_nvim() {
  local theme=$1
  local file="$CONFIG_DIR/nvim/lua/plugins/colorscheme.lua"

  if [[ "$theme" == "catppuccin" ]]; then
    sed -i '' 's/colorscheme = "gruvbox"/-- colorscheme = "gruvbox"/' "$file"
    sed -i '' 's/-- colorscheme = "catppuccin"/colorscheme = "catppuccin"/' "$file"
  else
    sed -i '' 's/colorscheme = "catppuccin"/-- colorscheme = "catppuccin"/' "$file"
    sed -i '' 's/-- colorscheme = "gruvbox"/colorscheme = "gruvbox"/' "$file"
  fi
}

_theme_update_tmux() {
  local theme=$1
  local file="$CONFIG_DIR/tmux/tmux.conf"

  if [[ "$theme" == "catppuccin" ]]; then
    sed -i '' 's|^source-file ~/.config/tmux/themes/gruvbox.conf|# source-file ~/.config/tmux/themes/gruvbox.conf|' "$file"
    sed -i '' 's|^# source-file ~/.config/tmux/themes/catppuccin.conf|source-file ~/.config/tmux/themes/catppuccin.conf|' "$file"
  else
    sed -i '' 's|^source-file ~/.config/tmux/themes/catppuccin.conf|# source-file ~/.config/tmux/themes/catppuccin.conf|' "$file"
    sed -i '' 's|^# source-file ~/.config/tmux/themes/gruvbox.conf|source-file ~/.config/tmux/themes/gruvbox.conf|' "$file"
  fi
}

_theme_update_starship() {
  local theme=$1
  local file="$CONFIG_DIR/starship/starship.sh"

  if [[ "$theme" == "catppuccin" ]]; then
    sed -i '' 's|^export STARSHIP_CONFIG=~/.config/starship/themes/gruvbox.toml|# export STARSHIP_CONFIG=~/.config/starship/themes/gruvbox.toml|' "$file"
    sed -i '' 's|^# export STARSHIP_CONFIG=~/.config/starship/themes/catppuccin.toml|export STARSHIP_CONFIG=~/.config/starship/themes/catppuccin.toml|' "$file"
  else
    sed -i '' 's|^export STARSHIP_CONFIG=~/.config/starship/themes/catppuccin.toml|# export STARSHIP_CONFIG=~/.config/starship/themes/catppuccin.toml|' "$file"
    sed -i '' 's|^# export STARSHIP_CONFIG=~/.config/starship/themes/gruvbox.toml|export STARSHIP_CONFIG=~/.config/starship/themes/gruvbox.toml|' "$file"
  fi
}

_theme_update_yazi() {
  local theme=$1
  local file="$CONFIG_DIR/yazi/theme.toml"

  if [[ "$theme" == "catppuccin" ]]; then
    sed -i '' 's/^dark = "gruvbox-dark"/# dark = "gruvbox-dark"/' "$file"
    sed -i '' 's/^light = "gruvbox-dark"/# light = "gruvbox-dark"/' "$file"
    sed -i '' 's/^# dark = "catppuccin-mocha"/dark = "catppuccin-mocha"/' "$file"
    sed -i '' 's/^# light = "catppuccin-mocha"/light = "catppuccin-mocha"/' "$file"
  else
    sed -i '' 's/^dark = "catppuccin-mocha"/# dark = "catppuccin-mocha"/' "$file"
    sed -i '' 's/^light = "catppuccin-mocha"/# light = "catppuccin-mocha"/' "$file"
    sed -i '' 's/^# dark = "gruvbox-dark"/dark = "gruvbox-dark"/' "$file"
    sed -i '' 's/^# light = "gruvbox-dark"/light = "gruvbox-dark"/' "$file"
  fi
}

_theme_update_bat() {
  local theme=$1
  local file="$CONFIG_DIR/bat/config"

  if [[ "$theme" == "catppuccin" ]]; then
    sed -i '' "s/^--theme='gruvbox-dark'/# --theme='gruvbox-dark'/" "$file"
    sed -i '' "s/^# --theme='Catppuccin Mocha'/--theme='Catppuccin Mocha'/" "$file"
  else
    sed -i '' "s/^--theme='Catppuccin Mocha'/# --theme='Catppuccin Mocha'/" "$file"
    sed -i '' "s/^# --theme='gruvbox-dark'/--theme='gruvbox-dark'/" "$file"
  fi
}

_theme_update_ghostty() {
  local theme=$1
  local file="$CONFIG_DIR/ghostty/config"

  if [[ "$theme" == "catppuccin" ]]; then
    sed -i '' 's/^theme = Gruvbox Dark/theme = Catppuccin Mocha/' "$file"
  else
    sed -i '' 's/^theme = Catppuccin Mocha/theme = Gruvbox Dark/' "$file"
  fi
}

_theme_update_zed() {
  local theme=$1
  local file="$CONFIG_DIR/zed/settings.json"

  if [[ "$theme" == "catppuccin" ]]; then
    sed -i '' 's/"theme": "Gruvbox Material"/"theme": "Catppuccin Mocha"/' "$file"
  else
    sed -i '' 's/"theme": "Catppuccin Mocha"/"theme": "Gruvbox Material"/' "$file"
  fi
}

_theme_update_lazygit() {
  local theme=$1
  local file="$CONFIG_DIR/lazygit/lazygit.sh"

  if [[ "$theme" == "catppuccin" ]]; then
    sed -i '' 's|^export LG_CONFIG_FILE=~/.config/lazygit/themes/gruvbox.yml|# export LG_CONFIG_FILE=~/.config/lazygit/themes/gruvbox.yml|' "$file"
    sed -i '' 's|^# export LG_CONFIG_FILE=~/.config/lazygit/themes/catppuccin.yml|export LG_CONFIG_FILE=~/.config/lazygit/themes/catppuccin.yml|' "$file"
  else
    sed -i '' 's|^export LG_CONFIG_FILE=~/.config/lazygit/themes/catppuccin.yml|# export LG_CONFIG_FILE=~/.config/lazygit/themes/catppuccin.yml|' "$file"
    sed -i '' 's|^# export LG_CONFIG_FILE=~/.config/lazygit/themes/gruvbox.yml|export LG_CONFIG_FILE=~/.config/lazygit/themes/gruvbox.yml|' "$file"
  fi
}

_theme_reload_apps() {
  # Reload tmux if running
  if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
    tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null && echo "    reloaded tmux"
  fi

  # Reload ghostty via SIGUSR1
  if pgrep -x ghostty >/dev/null 2>&1; then
    kill -SIGUSR1 $(pgrep -x ghostty) 2>/dev/null && echo "    reloaded ghostty"
  fi

  # Rebuild bat cache
  if command -v bat >/dev/null 2>&1; then
    bat cache --build >/dev/null 2>&1 && echo "    rebuilt bat cache"
  fi
}

# ===============================
# Main functions
# ===============================
theme-current() {
  local current=$(_theme_detect_current)
  echo "🎨 current theme: $current"
}

theme-switch() {
  local theme=$1

  if [[ "$theme" != "catppuccin" && "$theme" != "gruvbox" ]]; then
    echo "usage: theme-switch <catppuccin|gruvbox>"
    return 1
  fi

  local current=$(_theme_detect_current)
  if [[ "$current" == "$theme" ]]; then
    echo "🎨 already using $theme theme"
    return 0
  fi

  echo "🎨 switching to $theme theme..."
  echo ""

  echo "  📝 nvim..."
  _theme_update_nvim "$theme"

  echo "  📺 tmux..."
  _theme_update_tmux "$theme"

  echo "  ⭐ starship..."
  _theme_update_starship "$theme"

  echo "  📁 yazi..."
  _theme_update_yazi "$theme"

  echo "  🦇 bat..."
  _theme_update_bat "$theme"

  echo "  👻 ghostty..."
  _theme_update_ghostty "$theme"

  echo "  ⚡ zed..."
  _theme_update_zed "$theme"

  echo "  🦥 lazygit..."
  _theme_update_lazygit "$theme"

  echo ""
  echo "🔄 reloading apps..."
  _theme_reload_apps

  # Update env vars in current shell
  if [[ "$theme" == "catppuccin" ]]; then
    export STARSHIP_CONFIG=~/.config/starship/themes/catppuccin.toml
    export LG_CONFIG_FILE=~/.config/lazygit/themes/catppuccin.yml
  else
    export STARSHIP_CONFIG=~/.config/starship/themes/gruvbox.toml
    export LG_CONFIG_FILE=~/.config/lazygit/themes/gruvbox.yml
  fi

  echo ""
  echo "✅ switched to $theme theme!"
  echo ""
  echo "📋 restart these apps for changes:"
  echo "   • nvim, zed, yazi"
}

theme-catppuccin() {
  theme-switch catppuccin
}

theme-gruvbox() {
  theme-switch gruvbox
}

theme-toggle() {
  local current=$(_theme_detect_current)
  if [[ "$current" == "gruvbox" ]]; then
    theme-switch catppuccin
  else
    theme-switch gruvbox
  fi
}
