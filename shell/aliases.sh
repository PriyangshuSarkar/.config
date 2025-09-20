# General aliases
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'
alias brewsync='brew update && brew upgrade -g && brew cleanup'
alias za='zellij attach -c dev'
alias zk='zellij kill-session dev'
alias testzsh="echo Zsh is working!"

# Git helper aliases
alias gadd='git add .'

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

# Pull latest for current branch
gpull() {
  git fetch --all -p -P || return 1
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "Not on a branch (detached HEAD)."
    return 1
  fi
  git pull origin "$branch"
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

# Build & test helper
build_and_test() {
  echo "🔍 Detecting build system..."

  if [ -f package.json ]; then
    if command -v bun >/dev/null 2>&1; then
      bun run build || {
        echo "❌ Build failed."
        return 1
      }
      bun test || {
        echo "❌ Tests failed."
        return 1
      }
    elif command -v npm >/dev/null 2>&1; then
      npm run build || {
        echo "❌ Build failed."
        return 1
      }
      npm test || {
        echo "❌ Tests failed."
        return 1
      }
    elif command -v yarn >/dev/null 2>&1; then
      yarn build || {
        echo "❌ Build failed."
        return 1
      }
      yarn test || {
        echo "❌ Tests failed."
        return 1
      }
    fi
  elif [ -f Makefile ]; then
    make build || {
      echo "❌ Build failed."
      return 1
    }
    make test || {
      echo "❌ Tests failed."
      return 1
    }
  elif [ -f pyproject.toml ] || [ -f setup.py ]; then
    if command -v hatch >/dev/null 2>&1; then
      hatch build || {
        echo "❌ Build failed."
        return 1
      }
      hatch run test || {
        echo "❌ Tests failed."
        return 1
      }
    elif command -v poetry >/dev/null 2>&1; then
      poetry build || {
        echo "❌ Build failed."
        return 1
      }
      poetry run pytest || {
        echo "❌ Tests failed."
        return 1
      }
    else
      python -m build || {
        echo "❌ Build failed."
        return 1
      }
      pytest || {
        echo "❌ Tests failed."
        return 1
      }
    fi
  elif [ -f Cargo.toml ]; then
    cargo build --release || {
      echo "❌ Build failed."
      return 1
    }
    cargo test || {
      echo "❌ Tests failed."
      return 1
    }
  elif [ -f go.mod ]; then
    go build ./... || {
      echo "❌ Build failed."
      return 1
    }
    go test ./... || {
      echo "❌ Tests failed."
      return 1
    }
  elif [ -f pom.xml ]; then
    mvn package -DskipTests || {
      echo "❌ Build failed."
      return 1
    }
    mvn test || {
      echo "❌ Tests failed."
      return 1
    }
  elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
    gradle build -x test || {
      echo "❌ Build failed."
      return 1
    }
    gradle test || {
      echo "❌ Tests failed."
      return 1
    }
  else
    echo "⚠️  No known build system detected — skipping build and tests."
  fi

  echo "✅ Build and tests passed."
}

# Push current branch only if build succeeds
gpush() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  build_and_test || return 1
  echo "🔹 Pushing branch '$branch'..."
  git push origin "$branch"
}

# Rename, delete, and list branches
grename() {
  if [ -z "$1" ]; then
    echo "Usage: grename <new-branch-name> [old-branch-name]"
    return 1
  fi

  new_branch="$1"
  old_branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"

  if [ "$old_branch" = "HEAD" ]; then
    echo "Cannot rename detached HEAD."
    return 1
  fi

  git branch -m "$old_branch" "$new_branch" && echo "Branch '$old_branch' renamed to '$new_branch'."
}

gbranch() {
  if [ "$1" = "-a" ]; then
    git branch -a
  else
    git branch
  fi
}

gdelete() {
  if [ -z "$1" ]; then
    echo "Usage: gdelete <branch>"
    return 1
  fi

  branch="$1"
  if git branch -d "$branch"; then
    echo "Branch '$branch' deleted."
  else
    read -r -p "Safe delete failed. Force delete '$branch'? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] && git branch -D "$branch" && echo "Branch '$branch' force deleted."
  fi
}

# Sync with origin/main
gsync() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "Not on a branch (detached HEAD)."
    return 1
  fi

  git fetch --all -p -P || return 1

  if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
    git merge "origin/$branch" || return 1
  else
    echo "No remote branch found for $branch, skipping..."
  fi

  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    git merge origin/main
  else
    echo "origin/main not found"
    return 1
  fi
}
