# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managing configuration files for a macOS development environment. The repository uses Git for version control and follows conventional commit message standards (feat:, fix:, docs:, etc.).

## Architecture

### Shell Configuration Structure

The shell environment is split into modular components:

- **`shell/shell.sh`**: Cross-shell configuration (Bash/Zsh) that handles:
  - Shell detection and shell-specific setup
  - Editor mode (vi mode enabled)
  - PATH configuration
  - Completion systems (fzf, zoxide, starship)
  - Plugin loading for Zsh (autosuggestions, syntax highlighting, vi-mode)

- **`shell/aliases.sh`**: Consolidated aliases and Git helper functions:
  - Command aliases (lsd, bat, nvim)
  - Git workflow functions (`ga`, `gs`, `gc`, `gp`, etc.)
  - Branch management (`gsw`, `gn`, `gb`, `gr`, `gdel`)
  - `gsy` - intelligent branch sync that merges from remote origin and closest parent branch
  - Build/test automation (`bt` function detects and runs build systems)
  - Tmux helpers (`tad`, `tkd`)

- **`shell/dev_tmux.sh`**: Tmux session automation script that creates a "dev" session with:
  - 5 windows: home, api-nvim, api-term, web-nvim, web-term
  - Project-specific layouts for ~/Projects/ops-api and ~/Projects/ops-web
  - Split panes with nvim, claude CLI, and dev servers

### Neovim Configuration

LazyVim-based setup using lazy.nvim plugin manager:

- **Entry point**: `nvim/init.lua` loads `config.lazy`
- **Structure**: `nvim/lua/config/` contains core config (autocmds, keymaps, options)
- **Plugins**: `nvim/lua/plugins/` contains custom plugin configurations
- **Key plugins**: colorscheme, git integration, formatting, vim-tmux-navigator, lualine

### Tmux Configuration

- **Config file**: `tmux/tmux.conf`
- **Theme**: Catppuccin Mocha via catppuccin/tmux plugin
- **Key plugins**: tpm, tmux-sensible, vim-tmux-navigator, tmux-yank, tmux-resurrect, tmux-continuum, tmux-fzf
- **Keybindings**:
  - `|` for horizontal split
  - `-` for vertical split
  - `prefix r` to reload config
- **Features**: Mouse support, 256-color terminal, vi-mode copy

### Other Key Configurations

- **Starship prompt**: `starship/themes/` — Catppuccin and Gruvbox variants; active theme is `~/.config/starship.toml` (symlinked or copied via `starship-catppuccin` / `starship-gruvbox` shell functions)
- **Zed editor**: `zed/settings.json` — Vim mode enabled, Catppuccin theme, format on save with Prettier, relative line numbers
- **LazyGit**: `lazygit/` — Catppuccin Mocha color scheme
- **Aerospace**: macOS window manager, `aerospace/aerospace.toml`

## System Update Automation

**Script**: `shell/sysupdate.sh` - LaunchAgent-compatible automated update script

Runs with 10-minute timeout per operation and updates:
- Homebrew (update, upgrade, cleanup)
- Bun and npm global packages
- Neovim plugins (Lazy sync/update, Mason, MasonToolsUpdate, TSUpdate)
- Tmux plugins (via tpm)
- Yazi packages

**Log location**: `~/Library/Logs/sysupdate.log` (overwritten on each run)

**Constraint**: `sysupdate.sh` runs unattended via LaunchAgent — it must not require interactive input or a TTY, and must use absolute paths (shell aliases are not available).

## Common Commands

### Git Workflow Functions

All custom Git functions are defined in `shell/aliases.sh`:

```bash
ga              # git add .
gs              # git status -sb
gc              # git commit (uses git-cz if available via bun)
gca             # git commit --amend
gp              # git push (runs bt first, then pushes to origin)
gu              # git reset --soft HEAD~1

# Branch operations
gsw <branch>                    # Fetch all, then switch to branch
gn <new-branch> [base-branch]   # Create new branch from base (default: origin/main)
gb [-a]                         # List branches (or all with -a)
gr <new-name> [old-name]        # Rename branch
gdel <branch>                   # Delete branch (prompts for force if needed)

# Branch syncing
gsy [extra-branch]  # Intelligent sync: merges origin/<current>, closest parent, and optional extra branch

# Utilities
gl              # git log --oneline --graph --decorate --all
grl             # git reflog --decorate --color=auto
gd              # Show both unstaged and staged diffs
gstash / gstashp # git stash / git stash pop
```

### Build & Test

```bash
bt              # Auto-detect build system and run build + test
                # Supports: Node.js (bun/npm/yarn), Python (hatch/poetry), Rust, Go, Java (Maven/Gradle)
```

### Tmux

```bash
tad             # Launch dev_tmux.sh (creates or attaches to "dev" session)
tkd             # Kill tmux dev session (with confirmation)
```

### System Maintenance

```bash
brewsync        # brew update && brew upgrade -g && brew cleanup -s
starship-catppuccin   # switch starship prompt to Catppuccin theme
starship-gruvbox      # switch starship prompt to Gruvbox theme
```

### Neovim Updates

Updates are automated via `sysupdate.sh`, but can be run manually:

```bash
nvim --headless "+Lazy! sync" "+Lazy! update" "+qall"
nvim --headless "MasonUpdate" "+qall"
nvim --headless "MasonToolsUpdate" "+qall"
nvim --headless "+TSUpdate" "+qall"
```

## Important Notes

- **Vi mode everywhere**: Shell, nvim, tmux copy mode, and Zed all use vi keybindings
- **Theme consistency**: Catppuccin Mocha is primary across all tools; Gruvbox is the secondary alternative. When adding a new tool, configure it for Catppuccin Mocha first.
- **Shell compatibility**: `shell.sh` and `aliases.sh` must remain compatible with both Bash and Zsh; Zsh-only features are conditionally wrapped
- **`gp` runs `bt` first**: Every push triggers a build+test. Changes to `aliases.sh` that affect the `bt` function affect all git pushes.
- **Zsh branch completions**: `gsw`, `gdel`, `gn` autocomplete branch names via `_git_branch_completion`
- **Git commit style**: Conventional commits with emoji prefix (e.g. `feat: 🎸`, `fix: 🐛`, `chore: 🤖`, `refactor: ♻️`)
- **Preferred package managers**: bun (Node.js), brew (macOS packages)
- **Untracked directories**: `cursor/` and `ngrok/` are intentionally untracked; do not add them to git

## File Modification Guidelines

- **Shell scripts**: Keep `shell.sh` (env setup) and `aliases.sh` (functions/aliases) separate; don't merge them
- **Neovim plugins**: Add new plugins as separate files in `nvim/lua/plugins/`
- **Git functions**: All git helpers go in `shell/aliases.sh` with an `echo` showing the command being run (existing style)
- **Shell script style**: Maintain existing comment block separators (`# ===`) and emoji usage
