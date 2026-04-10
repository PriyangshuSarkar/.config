#!/bin/zsh -f
set -euo pipefail

# --- config ---
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# --- logging ---
logdir="$HOME/Library/Logs"
logfile="$logdir/sysupdate.log"

mkdir -p "$logdir"

# Detect interactive execution
interactive=false
if [[ -t 1 ]]; then
  interactive=true
else
  exec >"$logfile" 2>&1
fi

echo "========================================"
echo " Run started at $(date)"
echo " Mode: $([[ $interactive == true ]] && echo interactive || echo non-interactive)"
echo "========================================"

# --- helpers ---
run_cmd() {
  local description="$1"
  shift
  if [[ "$interactive" == "true" ]]; then
    echo ">>> Running: $description"
    "$@" || echo "!!! Failed: $description"
  else
    echo ">>> Running: $description (timeout 10m)"
    if command -v gtimeout >/dev/null 2>&1; then
      gtimeout 600 "$@" || echo "!!! Timed out or failed: $description"
    elif command -v timeout >/dev/null 2>&1; then
      timeout 600 "$@" || echo "!!! Timed out or failed: $description"
    else
      "$@" || echo "!!! Failed: $description"
    fi
  fi
}

# --- homebrew ---
if command -v brew >/dev/null 2>&1; then
  run_cmd "brew update" brew update
  if [[ "$interactive" == "true" ]]; then
    run_cmd "brew upgrade -g" brew upgrade -g
  else
    run_cmd "brew upgrade" brew upgrade
  fi
  run_cmd "brew cleanup --prune=all -s -v" brew cleanup --prune=all -s -v
fi

# --- mas (interactive only) ---
if [[ "$interactive" == "true" ]] && command -v mas >/dev/null 2>&1; then
  run_cmd "mas update" mas update
fi

# --- npm ---
if command -v npm >/dev/null 2>&1; then
  run_cmd "npm update -g" npm update -g
fi

# --- bun ---
if command -v bun >/dev/null 2>&1; then
  run_cmd "bun update -g" bun update -g
fi

# --- pipx ---
if command -v pipx >/dev/null 2>&1; then
  run_cmd "pipx upgrade-all" pipx upgrade-all
fi

# --- neovim ---
if command -v nvim >/dev/null 2>&1; then
  run_cmd "nvim lazy clean" nvim --headless "+Lazy! clean" "+qall"
  run_cmd "nvim lazy sync+update" nvim --headless "+Lazy! sync" "+Lazy! update" "+qall"
  run_cmd "nvim mason update" nvim --headless "MasonUpdate" "+qall"
  run_cmd "nvim mason-tool-installer update" nvim --headless "MasonToolsUpdateSync" "+qall"
  run_cmd "nvim treesitter update" nvim --headless "+TSUpdate" "+qall"
  run_cmd "nvim remote plugins update" nvim --headless "+UpdateRemotePlugins" "+qall"
fi

# --- tmux TPM ---
tpm_dir="$HOME/.tmux/plugins/tpm"
if [[ -d "$tpm_dir" ]]; then
  run_cmd "tmux tpm install" "$tpm_dir/bin/install_plugins"
  run_cmd "tmux tpm update" "$tpm_dir/bin/update_plugins" all
  run_cmd "tmux tpm clean" "$tpm_dir/bin/clean_plugins"
fi

# --- ya ---
if command -v ya >/dev/null 2>&1; then
  run_cmd "ya pkg upgrade" ya pkg upgrade
fi

# --- dprint ---
if command -v dprint >/dev/null 2>&1; then
  run_cmd "dprint fmt" dprint fmt
fi

# --- mo (interactive only) ---
if [[ "$interactive" == "true" ]] && command -v mo >/dev/null 2>&1; then
  run_cmd "mo update" mo update
  run_cmd "mo clean" mo clean
  run_cmd "mo optimize" mo optimize
fi

echo "========================================"
echo " Run finished at $(date)"
echo "========================================"
exit 0
