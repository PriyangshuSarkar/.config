# ===============================
# general aliases
# ===============================
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'
alias cat='bat'
alias vi='nvim'
alias vim='nvim'

# ===============================
# general functions
# ===============================
brewsync() {
  echo "🍺 $ brew update && brew upgrade -g && brew cleanup --prune=all -s -v"
  brew update
  brew upgrade -g
  brew cleanup --prune=all -s -v
}

mosync() {
  echo "🧹 $ mo update && mo optimize && mo clean"
  mo update
  mo optimize
  mo clean
}

sysupdate() {
  echo "🔄 $ $HOME/.config/shell/sysupdate.sh"
  "$HOME/.config/shell/sysupdate.sh"
}

ip() {
  echo "🌍 $ ipinfo myip $*"
  command ipinfo myip "$@"
}

# ===============================
# starship theme switcher
# ===============================
starship-theme() {
  local theme="$1"
  local src="$HOME/.config/starship/themes/${theme}.toml"
  if [[ ! -f "$src" ]]; then
    echo "unknown theme: $theme (available: catppuccin, gruvbox)"
    return 1
  fi
  echo "🎨 $ cp $src ~/.config/starship.toml"
  cp "$src" "$HOME/.config/starship.toml" &&
    echo "✅ switched to $theme theme. restart your shell or run: exec \$SHELL"
}
