# vim motions
bindkey -v

# 🟢 Efficient PATH prepending
export PATH="/Users/priyangshusarkar09/.bun/bin:/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/Users/priyangshusarkar09/.codeium/windsurf/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"   # ← add this

# 🟢 Load completion directories into fpath BEFORE compinit
fpath+=(
  "/Users/priyangshusarkar09/.bun"
  "/Users/priyangshusarkar09/.docker/completions"
  $(brew --prefix)/share/zsh-completions
)

# 🟢 Initialize completions only once, with cache
autoload -Uz compinit
compinit -C

# 🟢 Load fzf if installed
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# 🟢 Initialize zoxide
eval "$(zoxide init zsh)"
# alias cd='z'  # Replace cd with zoxide

# 🟢 Initialize Starship prompt
eval "$(starship init zsh)"
 
# 🟢 Zsh plugins from Homebrew
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # Must come last


# ✅ Optional UI tweaks
# Completion menu with arrow keys
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Better tab behavior
setopt AUTO_MENU          # Show menu on tab
setopt AUTO_LIST          # Auto list options
setopt COMPLETE_IN_WORD   # Tab complete in the middle of a word

# ✅ Aliases using lsd for better ls output
alias ls='lsd'
alias ll='lsd -l'         # Long format
alias la='lsd -la'        # Long format + hidden
alias lt='lsd --tree'     # Tree view

# Optional: Run `fastfetch` only on interactive launch
# [[ $- == *i* ]] && fastfetch
# Created by `pipx` on 2025-08-24 11:30:22
export PATH="$PATH:/Users/priyangshusarkar09/.local/bin"

# Zellij aliases

# Attach to (or create if missing) a "dev" session
alias za='zellij attach -c dev'

# Detach from current session
alias zk='zellij kill-session dev'

# 🍺 Homebrew alias
alias brewsync='brew update && brew upgrade -g && brew cleanup'

# Git aliases

# Sync with origin/main
gsync() {
  branch=$(git rev-parse --abbrev-ref HEAD)

  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "Not on a branch (detached HEAD)."
    return 1
  fi

  git fetch --all -p -P || return 1

  # Merge with remote counterpart if it exists
  if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
    git merge "origin/$branch" || return 1
  else
    echo "No remote branch found for $branch, skipping..."
  fi

  # Merge with origin/main if it exists
  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    git merge origin/main
  else
    echo "origin/main not found"
    return 1
  fi
}

# Add all changes
gadd() {
  git add .
}

# Commit using bunx git-cz if staged files exist, fallback to git
gcommit() {
  if git diff --cached --quiet; then
    echo "No staged changes to commit."
    return 1
  fi

  if command -v bun >/dev/null 2>&1; then
    bunx git-cz || git commit
  else
    git commit
  fi
}
# Switch branches
gswitch() {
  if [ -z "$1" ]; then
    echo "Usage: gswitch <branch>"
    return 1
  fi
  git switch "$1"
}

# Create new branch from origin/main
gnew() {
  if [ -z "$1" ]; then
    echo "Usage: gnew <branch>"
    return 1
  fi
  git switch -c "$1" origin/main
}

# Pull latest from remote for the current branch
gpull() {
  git fetch --all -p -P || return 1
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "Not on a branch (detached HEAD)."
    return 1
  fi
  git pull origin "$branch"
}

# Push current branch to origin, but only if build succeeds
gpush() {
  branch=$(git rev-parse --abbrev-ref HEAD)

  echo "🔍 Detecting build system..."

  if [ -f package.json ]; then
    # JavaScript / TypeScript (Node, Bun, Yarn)
    if command -v bun >/dev/null 2>&1; then
      echo "Running: bun run build"
      bun run build || { echo "❌ Build failed. Push aborted."; return 1; }
    elif command -v npm >/dev/null 2>&1; then
      echo "Running: npm run build"
      npm run build || { echo "❌ Build failed. Push aborted."; return 1; }
    elif command -v yarn >/dev/null 2>&1; then
      echo "Running: yarn build"
      yarn build || { echo "❌ Build failed. Push aborted."; return 1; }
    fi

  elif [ -f Makefile ]; then
    # Generic Makefile projects
    echo "Running: make build"
    make build || { echo "❌ Build failed. Push aborted."; return 1; }

  elif [ -f pyproject.toml ] || [ -f setup.py ]; then
    # Python projects
    echo "Running: python build (PEP 517/518)"
    if command -v hatch >/dev/null 2>&1; then
      hatch build || { echo "❌ Build failed. Push aborted."; return 1; }
    elif command -v poetry >/dev/null 2>&1; then
      poetry build || { echo "❌ Build failed. Push aborted."; return 1; }
    else
      python -m build || { echo "❌ Build failed. Push aborted."; return 1; }
    fi

  elif [ -f Cargo.toml ]; then
    # Rust projects
    echo "Running: cargo build --release"
    cargo build --release || { echo "❌ Build failed. Push aborted."; return 1; }

  elif [ -f go.mod ]; then
    # Go projects
    echo "Running: go build ./..."
    go build ./... || { echo "❌ Build failed. Push aborted."; return 1; }

  elif [ -f pom.xml ]; then
    # Java (Maven)
    echo "Running: mvn package -DskipTests"
    mvn package -DskipTests || { echo "❌ Build failed. Push aborted."; return 1; }

  elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
    # Java/Kotlin (Gradle)
    echo "Running: gradle build -x test"
    gradle build -x test || { echo "❌ Build failed. Push aborted."; return 1; }

  else
    echo "⚠️  No known build system detected — skipping build."
  fi

  # If build succeeded (or skipped), push branch
  echo "✅ Build passed. Pushing branch '$branch'..."
  git push origin "$branch"
}
alias testzsh="echo Zsh is working!"


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/priyangshusarkar/.opam/opam-init/init.zsh' ]] || source '/Users/priyangshusarkar/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration
