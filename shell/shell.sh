#!/usr/bin/env bash
# Common shell configuration for both Bash and Zsh

# Detect shell
if [ -n "$BASH_VERSION" ]; then
  SHELL_TYPE="bash"
elif [ -n "$ZSH_VERSION" ]; then
  SHELL_TYPE="zsh"
else
  SHELL_TYPE="unknown"
fi

# -----------------------------
# Editor mode (works in both)
# -----------------------------
set -o vi

# -----------------------------
# PATH (works in both)
# -----------------------------
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="$HOME/.bun/bin:/opt/homebrew/opt/openjdk/bin:$HOME/.codeium/windsurf/bin:/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"

# -----------------------------
# Bash-specific configuration
# -----------------------------
if [ "$SHELL_TYPE" = "bash" ]; then
  shopt -s progcomp
  bind 'set show-all-if-ambiguous on'
  bind 'set completion-ignore-case on'

  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
  command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
fi

# -----------------------------
# Zsh-specific configuration
# -----------------------------
if [ "$SHELL_TYPE" = "zsh" ]; then
  # fpath completions
  fpath+=(
    "$HOME/.bun"
    "$HOME/.docker/completions"
    $(brew --prefix)/share/zsh-completions
  )
  autoload -Uz compinit
  compinit -C

  # fzf
  FZF_PREFIX=$(brew --prefix)/opt/fzf
  [[ -f $FZF_PREFIX/shell/key-bindings.zsh ]] && source $FZF_PREFIX/shell/key-bindings.zsh
  [[ -f $FZF_PREFIX/shell/completion.zsh ]] && source $FZF_PREFIX/shell/completion.zsh

  # zoxide and starship
  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
  command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

  # Zsh plugins
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $(brew --prefix)/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
  ZVM_SYSTEM_CLIPBOARD_ENABLED=true
  ZVM_VI_EDITOR="nvim"
  source $(brew --prefix)/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

  # Completion styles
  zstyle ':completion:*' menu select
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
  setopt AUTO_MENU AUTO_LIST COMPLETE_IN_WORD

  # OPAM
  [[ -r "$HOME/.opam/opam-init/init.zsh" ]] && source "$HOME/.opam/opam-init/init.zsh" >/dev/null 2>&1

  # Mole shell completion
  if output="$(mole completion zsh 2>/dev/null)"; then eval "$output"; fi
fi

# -----------------------------
# Text Editor
# -----------------------------
export EDITOR=nvim
export VISUAL=nvim

# -----------------------------
# Common interactive-only commands
# -----------------------------
[[ $- == *i* ]] && command -v fastfetch >/dev/null 2>&1 &&
  {
    while [ "$(tput cols)" -eq 0 ] || [ "$(tput lines)" -eq 0 ]; do
      sleep 0.05
    done
    fastfetch
  }

# -----------------------------
# Load shared aliases + Git functions
# -----------------------------
[[ -f "$HOME/.config/shell/aliases.sh" ]] && source "$HOME/.config/shell/aliases.sh"

# -----------------------------
# Load system-local overrides (not tracked in git)
# -----------------------------
if [[ -d "$HOME/.config/shell/local" ]]; then
  for f in "$HOME/.config/shell/local/"*.sh; do
    [[ -f "$f" ]] && source "$f"
  done
fi
