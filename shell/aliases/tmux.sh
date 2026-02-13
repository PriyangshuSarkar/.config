# ===============================
# tmux helpers
# ===============================
tad() {
  echo "💻 $ source ~/.config/shell/dev_tmux.sh"
  source ~/.config/shell/dev_tmux.sh
}

tkd() {
  if ! tmux has-session -t dev 2>/dev/null; then
    echo "ℹ️  no dev session running"
    return 0
  fi

  local confirm
  echo -n "💀 kill tmux session 'dev'? [y/N]: "
  read -r confirm
  if [[ "$confirm" =~ ^[yY]$ ]]; then
    echo "⚡ $ tmux kill-session -t dev"
    tmux kill-session -t dev && echo "✅ session 'dev' killed."
  else
    echo "🚫 session 'dev' not killed."
  fi
}
