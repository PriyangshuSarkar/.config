#!/bin/zsh -f
set -euo pipefail

# --- config ---
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# --- logging ---
logdir="$HOME/Library/Logs"
logfile="$logdir/sysupdate.log"
statefile="$logdir/.sysupdate.lastdate"

mkdir -p "$logdir"

today="$(date +%Y-%m-%d)"

# Truncate log once per new day
if [[ ! -f "$statefile" ]] || [[ "$(cat "$statefile")" != "$today" ]]; then
  : > "$logfile"
  echo "$today" > "$statefile"
fi

# Append for all runs today
exec >> "$logfile" 2>&1

echo "========================================"
echo " Run started at $(date)"
echo "========================================"

# --- helpers ---
run_with_timeout() {
  # $1 = command description
  # rest = command
  local description="$1"
  shift

  echo ">>> Running: $description (timeout 10m)"

  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout 600 "$@" || echo "!!! Timed out or failed: $description"
  elif command -v timeout >/dev/null 2>&1; then
    timeout 600 "$@" || echo "!!! Timed out or failed: $description"
  else
    "$@" || echo "!!! Failed: $description"
  fi
}

# --- homebrew ---
if command -v brew >/dev/null 2>&1; then
  run_with_timeout "brew update" brew update
  run_with_timeout "brew upgrade -g" brew upgrade -g
  run_with_timeout "brew cleanup --prune=all -s -v" brew cleanup --prune=all -s -v
fi

# --- npm ---
if command -v npm >/dev/null 2>&1; then
  run_with_timeout "npm update -g" npm update -g
fi

# --- bun ---
if command -v bun >/dev/null 2>&1; then
  run_with_timeout "bun update -g" bun update -g
fi

# --- pipx ---
if command -v pipx >/dev/null 2>&1; then
  run_with_timeout "pipx upgrade-all" pipx upgrade-all
fi

# --- neovim ---
if command -v nvim >/dev/null 2>&1; then
  run_with_timeout "nvim lazy clean" nvim --headless "+Lazy! clean" "+qall"
  run_with_timeout "nvim lazy sync+update" nvim --headless "+Lazy! sync" "+Lazy! update" "+qall"
  run_with_timeout "nvim mason update" nvim --headless "MasonUpdate" "+qall"
  run_with_timeout "nvim mason-tool-installer update" nvim --headless "MasonToolsUpdate" "+qall"
  run_with_timeout "nvim treesitter update" nvim --headless "+TSUpdate" "+qall"
  run_with_timeout "nvim remote plugins update" nvim --headless "+UpdateRemotePlugins" "+qall"
fi

# --- tmux TPM ---
tpm_dir="$HOME/.tmux/plugins/tpm"
if [[ -d "$tpm_dir" ]]; then
  run_with_timeout "tmux tpm install" "$tpm_dir/bin/install_plugins"
  run_with_timeout "tmux tpm update" "$tpm_dir/bin/update_plugins" all
  run_with_timeout "tmux tpm clean" "$tpm_dir/bin/clean_plugins"
fi


# --- ya ---
if command -v ya >/dev/null 2>&1; then
  run_with_timeout "ya pkg upgrade" ya pkg upgrade
fi

echo "========================================"
echo " Run finished at $(date)"
echo "========================================"
exit 0
