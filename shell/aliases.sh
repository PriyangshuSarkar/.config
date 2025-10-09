# ===============================
# General aliases
# ===============================
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'
alias brewsync='brew update; brew upgrade -g; brew cleanup'
alias vi='nvim'
alias vim='nvim'
alias tad='source ~/.config/shell/dev_tmux.sh'
alias tkd='tmux has-session -t dev 2>/dev/null && tmux kill-session -t dev || echo "No dev session running"'
alias cmatrix='cmatrix -ba -C cyan'
alias matrix='cmatrix -ba -C cyan'

# ===============================
# Git helper aliases
# ===============================
alias ga='git add .'
alias gs='git status -sb'
alias gundo='git reset --soft HEAD~1'
alias gstash='git stash'
alias gstashpop='git stash pop'
alias glog='git log --oneline --graph --decorate --all'
alias greflog='git reflog --decorate --color=auto'

# ===============================
# Git branch functions
# ===============================

gswitch() {
  if [ -z "$1" ]; then
    echo "Usage: gswitch <branch>"
    return 1
  fi
  git fetch --all -p -P
  git switch "$1"
}

gnew() {
  if [ -z "$1" ]; then
    echo "Usage: gnew <branch>"
    return 1
  fi
  git switch -c "$1" origin/main
}

gbranch() {
  if [ "$1" = "-a" ]; then
    git branch -a
  else
    git branch
  fi
}

gdiff() {
  echo "🔹 Unstaged changes:"
  git diff --color | sed 's/^/    /' # indent unstaged diff for clarity
  echo
  echo "🔹 Staged changes:"
  git diff --staged --color | sed 's/^/    /' # indent staged diff
}

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

gdelete() {
  if [ -z "$1" ]; then
    echo "Usage: gdelete <branch>"
    return 1
  fi
  branch="$1"

  if git branch -d "$branch" 2>/dev/null; then
    echo "Branch '$branch' deleted safely."
    return 0
  fi

  echo -n "Safe delete failed. Force delete '$branch'? [y/N]: "
  read confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git branch -D "$branch" && echo "Branch '$branch' force deleted."
  else
    echo "Branch '$branch' not deleted."
  fi
}

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

# ===============================
# Git commit & push helpers
# ===============================
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

gpush() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  build_and_test || return 1
  echo "🔹 Pushing branch '$branch'..."
  git push origin "$branch"
}

# ===============================
# Build & test helper
# ===============================
build_and_test() {
  echo "🔍 Detecting build system..."
  # Node.js
  if [ -f package.json ]; then
    if command -v bun >/dev/null 2>&1; then
      bun run build && bun run test
    elif command -v npm >/dev/null 2>&1; then
      npm run build && npm run test
    elif command -v yarn >/dev/null 2>&1; then
      yarn run build && yarn run test
    fi
  # Python
  elif [ -f pyproject.toml ] || [ -f setup.py ]; then
    if command -v hatch >/dev/null 2>&1; then
      hatch build && hatch run test
    elif command -v poetry >/dev/null 2>&1; then
      poetry build && poetry run pytest
    else
      python -m build && pytest
    fi
  # Rust
  elif [ -f Cargo.toml ]; then
    cargo build --release && cargo test
  # Go
  elif [ -f go.mod ]; then
    go build ./... && go test ./...
  # Java (Maven/Gradle)
  elif [ -f pom.xml ]; then
    mvn package -DskipTests && mvn test
  elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
    gradle build -x test && gradle test
  else
    echo "⚠️ No known build system detected — skipping build and tests."
  fi

  echo "✅ Build and tests passed."
}

# ===============================
# Auto-completion for branches
# ===============================
_git_branch_completion() {
  local branches
  branches=($(git for-each-ref --format='%(refname:short)' refs/heads/))
  _arguments "1:branch name:(${branches[*]})"
}

compdef _git_branch_completion gswitch gdelete gnew
