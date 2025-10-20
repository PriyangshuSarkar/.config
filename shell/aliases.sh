# ===============================
# General Aliases
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
# Git Basic Aliases
# ===============================
alias ga='git add .'
alias gau='git add -u'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gr1='git reset --soft HEAD~1'
alias grh='git reset --hard'
alias gl='git log --oneline --graph --decorate --all'
alias grl='git reflog --decorate --color=auto'

# ===============================
# Git Stash Aliases
# ===============================
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstd='git stash drop'

# ===============================
# Git Commit / Push / Pull Aliases
# ===============================
alias gca='git commit -a'
alias gcm='git commit -m'
alias gcf='git commit --fixup'
alias gco='git checkout'

alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gpa='git push --all'

# ===============================
# Git Branch Aliases
# ===============================
alias gb='git branch'
alias gba='git branch -a'
alias gbv='git branch -vv'

# ===============================
# Git Branch Functions
# ===============================

gbn() {
  if [ -z "$1" ]; then
    echo "Usage: gbn <branch>"
    return 1
  fi
  git switch -c "$1" origin/main
}

gbr() {
  if [ -z "$1" ]; then
    echo "Usage: gbr <new-branch-name> [old-branch-name]"
    return 1
  fi
  new_branch="$1"
  old_branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"

  if [ "$old_branch" = "HEAD" ]; then
    echo "Cannot rename detached HEAD."
    return 1
  fi

  git branch -m "$old_branch" "$new_branch" &&
    echo "Branch '$old_branch' renamed to '$new_branch'."
}

gbd() {
  if [ -z "$1" ]; then
    echo "Usage: gbd <branch>"
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

# ===============================
# Git Diff Helper
# ===============================
gdf() {
  echo "🔹 Unstaged changes:"
  git diff --color | sed 's/^/    /'
  echo
  echo "🔹 Staged changes:"
  git diff --staged --color | sed 's/^/    /'
}

# ===============================
# Git Sync Helpers
# ===============================
gup() {
  git fetch --all -p -P
  branch=$(git rev-parse --abbrev-ref HEAD)
  [ "$branch" != "HEAD" ] && git merge "origin/$branch"
}

gsy() {
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
# Git Commit Helper (Commitizen / Bun)
# ===============================
gc() {
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

# ===============================
# Build & Test Helper
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
  # Java
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
# Git Push Helper (with Build/Test)
# ===============================
gpu() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  build_and_test || return 1
  echo "🔹 Pushing branch '$branch'..."
  git push origin "$branch"
}

# ===============================
# Branch Name Autocompletion
# ===============================
_git_branch_completion() {
  local branches
  branches=($(git for-each-ref --format='%(refname:short)' refs/heads/))
  _arguments "1:branch name:(${branches[*]})"
}

compdef _git_branch_completion gbr gbd gbn
