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

