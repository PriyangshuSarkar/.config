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
  - `gsy` - branch sync that merges in the remote tracking branch and an optional extra branch; `--all` syncs every local branch

- **`shell/local/herdr.sh`** (gitignored, system-specific): Herdr session helpers (`had`, `hkd`)

- **`shell/local/ops_herdr`**: Herdr session script for the ops project — creates a named "ops" session (headless server, then attach) with:
  - 3 workspaces: `api`, `web`, `home` (opens on home); the sidebar groups each project's agents under its workspace
  - `api` and `web` each have 2 tabs: `nvim` (nvim | claude) and `term` (dev server over a shell), for ~/Projects/ops/api and ~/Projects/ops/web

- **`shell/local/battery_herdr`**: Herdr session script for the battery project — same structure as ops with workspaces `be` and `fe` (~/Projects/battery/back-end and ~/Projects/battery/front-end) plus `home` (session name: "battery")

### Neovim Configuration

LazyVim-based setup using lazy.nvim plugin manager:

- **Entry point**: `nvim/init.lua` loads `config.lazy`
- **Structure**: `nvim/lua/config/` contains core config (autocmds, keymaps, options)
- **Plugins**: `nvim/lua/plugins/` contains custom plugin configurations
- **Key plugins**: colorscheme, git integration, formatting, vim-herdr-navigation (only loaded inside Herdr), lualine

### Herdr Configuration

Herdr (terminal workspace manager for AI agents) replaces tmux.

- **Config file**: `herdr/config.toml` — the only tracked file in `herdr/`; sessions, sockets, logs and installed plugins are gitignored
- **Theme**: built-in `catppuccin`
- **Plugins**: `vim-herdr-navigation` (installed with `herdr plugin install paulbkim-dev/vim-herdr-navigation`)
- **Keybindings**: default prefix `ctrl+b`; `ctrl+h/j/k/l` are bound to the navigation plugin's actions (forward to nvim when it is in the foreground, otherwise move pane focus)
- **Reload config**: `prefix+shift+r` or `herdr server reload-config`

### Other Key Configurations

- **Starship prompt**: `starship.toml` (repo root) — ANSI terminal colors (inherits the Ghostty Catppuccin Mocha palette); initialized in `shell/shell.sh` (`starship init bash`/`zsh`)
- **LazyGit**: `lazygit/` — generic terminal colors (no custom theme)
- **Aerospace**: macOS window manager, `aerospace/aerospace.toml`

## System Update Automation

**Script**: `shell/sysupdate.sh` - LaunchAgent-compatible automated update script

Runs with 10-minute timeout per operation and updates:

- Homebrew (update, upgrade, cleanup)
- Bun and npm global packages
- Neovim plugins (Lazy sync/update, Mason, MasonToolsUpdate, TSUpdate)
- Herdr plugins (`herdr plugin update`)
- Yazi packages

**Log location**: `~/Library/Logs/sysupdate.log` (overwritten on each run)

**Constraint**: `sysupdate.sh` runs unattended via LaunchAgent — it must not require interactive input or a TTY, and must use absolute paths (shell aliases are not available).

## Common Commands

### Git Workflow Functions

All custom Git functions are defined in `shell/aliases.sh`:

```bash
ga              # git add .
gs              # git status -sb
gc              # git commit (supports arguments)
gcx             # git-cz (uses git-cz if available via bun)
gca             # git commit --amend
gp [--all]      # git push (current branch, or every local branch with --all; failures are skipped, not fatal)
gu              # git reset --soft HEAD~1

# Branch operations
gsw <branch>                    # Fetch all, then switch to branch
gn <new-branch> [base-branch]   # Create new branch from base (default: origin/main)
gb [-a]                         # List branches (or all with -a)
gr <new-name> [old-name]        # Rename branch
gdel <branch>                   # Delete branch (prompts for force if needed)

# Branch syncing
gsy [--all] [extra-branch]  # Merge in origin/<current> and optional extra branch; --all syncs every local branch (aborts + continues past conflicts)

# Utilities
gl              # git log --oneline --graph --decorate --all
grl             # git reflog --decorate --color=auto
gd              # Show both unstaged and staged diffs
gstash / gstashp # git stash / git stash pop
```

### Herdr

```bash
had ops         # Attach to running "ops" herdr session, else build it fresh (~/Projects/ops/api + web)
had battery     # Same for "battery" (~/Projects/battery/back-end + front-end)
had -c ops      # --continue: restore a stopped session as-is (old layout + claude --resume) instead of rebuilding
hkd ops         # Stop "ops" herdr session (with confirmation); kept on disk for `had -c`
hkd battery     # Stop "battery" herdr session (with confirmation)
```

### System Maintenance

```bash
brewsync        # brew update && brew upgrade -g && brew autoremove -v && brew cleanup --prune=all -s -v
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

- **Vi mode everywhere**: Shell, nvim, and herdr copy mode all use vi keybindings
- **Theme**: Catppuccin Mocha is the exclusive theme across all tools (ANSI-based tools inherit it from Ghostty) for visual consistency.
- **Shell compatibility**: `shell.sh` and `aliases.sh` must remain compatible with both Bash and Zsh; Zsh-only features are conditionally wrapped
- **Zsh branch completions**: `gsw`, `gdel`, `gn` autocomplete branch names via `_git_branch_completion`
- **Git commit style**: Must match [git-cz](https://github.com/streamich/git-cz) output exactly — see [Commit Message Rules](#commit-message-rules)
- **Preferred package managers**: bun (Node.js), brew (macOS packages)
- **Untracked directories**: `cursor/` and `ngrok/` are intentionally untracked; do not add them to git

## File Modification Guidelines

- **Shell scripts**: Keep `shell.sh` (env setup) and `aliases.sh` (functions/aliases) separate; don't merge them
- **Neovim plugins**: Add new plugins as separate files in `nvim/lua/plugins/`
- **Git functions**: All git helpers go in `shell/aliases.sh` with an `echo` showing the command being run (existing style)
- **Shell script style**: Maintain existing comment block separators (`# ===`) and emoji usage

## Commit Message Rules

Every commit message must be exactly what [git-cz](https://github.com/streamich/git-cz) would produce (defaults from `lib/defaults.js` and `lib/formatCommitMessage.js`). Never use a type or emoji outside this table.

| Type | Emoji | Use for |
| --- | --- | --- |
| `feat` | 🎸 | A new feature |
| `fix` | 🐛 | A bug fix |
| `chore` | 🤖 | Build process or auxiliary tool changes |
| `docs` | ✏️ | Documentation only changes |
| `refactor` | 💡 | A code change that neither fixes a bug nor adds a feature |
| `style` | 💄 | Markup, white-space, formatting, missing semi-colons... |
| `perf` | ⚡️ | A code change that improves performance |
| `test` | 💍 | Adding missing tests |
| `ci` | 🎡 | CI related changes |
| `release` | 🏹 | Create a release commit |

**Layout** (every section except the header is optional):

```
<type>(<scope>): <emoji> <subject>

<body, wrapped at 72 columns>

BREAKING CHANGE: 🧨 <description>

✅ Closes: <issues, e.g. #123>
```

- **Header**: `type(scope): emoji subject` — one space after the colon, one space between emoji and subject. Omit the parentheses entirely when there is no scope (`feat: 🎸 add keymap`).
- **Subject**: imperative, present tense ("add", not "added"), no trailing period, 3–61 characters (64-character header budget minus the emoji and space), lowercase start.
- **Body**: blank line after the header; explain motivation and contrast with previous behavior; wrap at 72 columns.
- **Breaking changes**: blank line, then `BREAKING CHANGE: 🧨 ` followed by the description.
- **Issues**: blank line, then `✅ Closes: ` followed by the issue refs.
- Trailers required by the harness (e.g. `Co-Authored-By`, `Claude-Session`) go last, after a blank line.
- One logical change per commit; never invent types (`feat!`, `build`, etc.).
