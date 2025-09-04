# 🟢 Efficient PATH prepending
export PATH="/Users/priyangshusarkar09/.bun/bin:/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/Users/priyangshusarkar09/.codeium/windsurf/bin:$PATH"
export PATH="/Users/priyangshusarkar09/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH" # ← add this line

# 🟢 Auto-Warpify (Warp terminal integration)
if [[ $- == *i* ]]; then
  printf '\033P$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "bash", "uname": "Darwin" }}\033\\'
fi

# 🟢 Load fzf if installed
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# 🟢 Initialize zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
  # alias cd='z'   # uncomment if you want zoxide to replace cd
fi

# 🟢 Initialize Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# 🟢 Bash completion (similar to zsh completions)
if [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
  . /opt/homebrew/etc/profile.d/bash_completion.sh
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# 🟢 Enable autosuggestions (via bash-preexec + bash-completion alternative)
# Note: Bash doesn't support zsh-autosuggestions directly.
# You can install https://github.com/miguelmota/bash-autosuggestions for similar behavior.
if [ -f /opt/homebrew/share/bash-autosuggestions/bash-autosuggestions.sh ]; then
  . /opt/homebrew/share/bash-autosuggestions/bash-autosuggestions.sh
fi

# ✅ Aliases using lsd for better ls output
alias ls='lsd'
alias ll='lsd -l'     # Long format
alias la='lsd -la'    # Long format + hidden
alias lt='lsd --tree' # Tree view

# ✅ Zellij aliases
alias za='zellij attach -c dev'
alias zk='zellij kill-session dev'

# 🍺 Homebrew alias
alias brewsync='brew update && brew upgrade -g && brew cleanup'

# ✅ Git aliases & functions

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
    if command -v bun >/dev/null 2>&1; then
      echo "Running: bun run build"
      bun run build || {
        echo "❌ Build failed. Push aborted."
        return 1
      }
    elif command -v npm >/dev/null 2>&1; then
      echo "Running: npm run build"
      npm run build || {
        echo "❌ Build failed. Push aborted."
        return 1
      }
    elif command -v yarn >/dev/null 2>&1; then
      echo "Running: yarn build"
      yarn build || {
        echo "❌ Build failed. Push aborted."
        return 1
      }
    fi

  elif [ -f Makefile ]; then
    echo "Running: make build"
    make build || {
      echo "❌ Build failed. Push aborted."
      return 1
    }

  elif [ -f pyproject.toml ] || [ -f setup.py ]; then
    echo "Running: python build (PEP 517/518)"
    if command -v hatch >/dev/null 2>&1; then
      hatch build || {
        echo "❌ Build failed. Push aborted."
        return 1
      }
    elif command -v poetry >/dev/null 2>&1; then
      poetry build || {
        echo "❌ Build failed. Push aborted."
        return 1
      }
    else
      python -m build || {
        echo "❌ Build failed. Push aborted."
        return 1
      }
    fi

  elif [ -f Cargo.toml ]; then
    echo "Running: cargo build --release"
    cargo build --release || {
      echo "❌ Build failed. Push aborted."
      return 1
    }

  elif [ -f go.mod ]; then
    echo "Running: go build ./..."
    go build ./... || {
      echo "❌ Build failed. Push aborted."
      return 1
    }

  elif [ -f pom.xml ]; then
    echo "Running: mvn package -DskipTests"
    mvn package -DskipTests || {
      echo "❌ Build failed. Push aborted."
      return 1
    }

  elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
    echo "Running: gradle build -x test"
    gradle build -x test || {
      echo "❌ Build failed. Push aborted."
      return 1
    }

  else
    echo "⚠️  No known build system detected — skipping build."
  fi

  echo "✅ Build passed. Pushing branch '$branch'..."
  git push origin "$branch"
}
