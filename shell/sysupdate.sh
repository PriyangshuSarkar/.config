#!/bin/zsh -f
set -euo pipefail

# --- config ---
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# fixed log path
logfile="$HOME/Library/Logs/sysupdate.log"
mkdir -p "$(dirname "$logfile")"

# overwrite
exec > "$logfile" 2>&1

echo "---- run at $(date) ----"

run_with_timeout() {
  # $1 = command description (string)
  # rest = command to run
  local description="$1"
  shift
  echo ">>> Running: $description (timeout 10m)"
  
  # Check if gtimeout exists, fallback to timeout, or run without timeout
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout 600 "$@" || echo "!!! Timed out or failed: $description"
  elif command -v timeout >/dev/null 2>&1; then
    timeout 600 "$@" || echo "!!! Timed out or failed: $description"
  else
    "$@" || echo "!!! Failed: $description"
  fi
}

# homebrew
if command -v brew >/dev/null; then
  run_with_timeout "brew update" brew update
  run_with_timeout "brew upgrade -g" brew upgrade -g
  run_with_timeout "brew cleanup -s" brew cleanup -s
fi

# bun
if command -v bun >/dev/null; then
  run_with_timeout "bun update -g" bun update -g
fi

# npm
if command -v npm >/dev/null; then
  run_with_timeout "npm update -g" npm update -g
fi

# neovim
if command -v nvim >/dev/null; then
  run_with_timeout "nvim lazy sync+update" nvim --headless "+Lazy! sync" "+Lazy! update" "+qall"
  run_with_timeout "nvim mason update" nvim --headless "MasonUpdate" "+qall"
  run_with_timeout "nvim mason-tool-installer update" nvim --headless "MasonToolsUpdate" "+qall"
fi

# tmux tpm plugins
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  run_with_timeout "tmux tpm update" "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
  run_with_timeout "tmux tpm clean" "$HOME/.tmux/plugins/tpm/bin/clean_plugins"
fi

echo "---- finished at $(date) ----"
exit 0
