#!/bin/zsh -f
set -euo pipefail

# --- config ---
TIMEOUT="gtimeout 600"   # 10 minutes
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# fixed log path
logfile="$HOME/library/logs/sysupdate.log"
mkdir -p "$(dirname "$logfile")"
exec >> "$logfile" 2>&1

echo "---- run at $(date) ----"

run_with_timeout() {
  # $1 = command description (string)
  # $@ = command to run
  shift
  echo ">>> Running: $* (timeout 10m)"
  $TIMEOUT "$@" || echo "!!! Timed out or failed: $*"
}

# homebrew
if command -v brew >/dev/null; then
  run_with_timeout brew update --quiet
  run_with_timeout brew upgrade --quiet
  run_with_timeout brew cleanup --quiet
fi

# bun
if command -v bun >/dev/null; then
  run_with_timeout bun update -g
fi

# npm
if command -v npm >/dev/null; then
  run_with_timeout npm update -g --no-fund --no-audit
fi

# neovim
if command -v nvim >/dev/null; then
  run_with_timeout nvim --headless "+lazy! update" "+qall"
  run_with_timeout nvim --headless "masonupdate" "+qall"
  run_with_timeout nvim --headless "masontoolsupdate" "+qall"
fi

# tmux tpm plugins
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  run_with_timeout "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
  run_with_timeout "$HOME/.tmux/plugins/tpm/bin/clean_plugins"
fi

echo "---- finished at $(date) ----"
exit 0
