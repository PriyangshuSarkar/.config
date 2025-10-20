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
# Git Aliases — Core
# ===============================
alias ga='git add .'
alias gau='git add -u'
alias gap='git add -p'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate --all'
alias grl='git reflog --decorate --color=auto'

# Safer reset aliases
alias grs='git reset --soft HEAD~1'
alias grm='git reset --mixed HEAD~1'
alias grh='echo "⚠️ Use grhf to force hard reset";'
alias grhf='git reset --hard'

# ===============================
# Git Commit / Push / Pull
# ===============================
alias gcm='git commit -m'
alias gca='git commit -a'
alias gcf='git commit --fixup'
alias gcA='git commit --amend --no-edit'

alias gpl='git pull --rebase --autostash'
alias gp='git push'
alias gpf='echo "⚠️ Use gpF for force push";'
alias gpF='git push --force-with-lease'
alias gpa='git push --all'

# ===============================
# Git Branch — Core
# ===============================
alias gb='git branch'
alias gba='git branch -a'
alias gbv='git branch -vv'

# ===============================
# Git Branch — Functions
# ===============================

# Create new branch from origin/main
gbn() {
  if [ -z "$1" ]; then
    echo "Usage: gbn <branch-name>"
    return 1
  fi
  git fetch origin main >/dev/null 2>&1
  git switch -c "$1" origin/main && echo "✅ Created branch '$1' from origin/main"
}

# Rename current or target branch
gbr() {
  if [ -z "$1" ]; then
    echo "Usage: gbr <new-name> [old-name]"
    return 1
  fi
  new="$1"
  old="${2:-$(git rev-parse --abbrev-ref HEAD)}"
  [ "$old" = "HEAD" ] && echo "❌ Detached HEAD — cannot rename." && return 1
  git branch -m "$old" "$new" && echo "✅ Renamed branch '$old' → '$new'"
}

# Delete branch safely with confirmation
gbd() {
  if [ -z "$1" ]; then
    echo "Usage: gbd <branch-name>"
    return 1
  fi
  branch="$1"
  if git branch -d "$branch" 2>/dev/null; then
    echo "🗑️  Deleted branch '$branch' safely."
  else
    read -p "⚠️  Force delete '$branch'? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] && git branch -D "$branch" && echo "✅ Force deleted '$branch'"
  fi
}

# ===============================
# Git Stash
# ===============================
alias gst='git stash push'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstd='git stash drop'

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
# Git Update / Sync Helpers
# ===============================

# Fetch + merge current branch
gup() {
  git fetch --all -p
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  [ "$branch" != "HEAD" ] && git merge "origin/$branch"
}

# Sync current branch with its remote and main
gsy() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  [ "$branch" = "HEAD" ] && echo "❌ Detached HEAD — cannot sync." && return 1
  git fetch --all -p
  git merge --ff-only "origin/$branch" 2>/dev/null || echo "⚠️  No remote branch for '$branch'"
  git merge --ff-only origin/main 2>/dev/null || echo "⚠️  origin/main not found"
  echo "✅ Branch synced."
}

# ===============================
# Commit Helper (with Commitizen/Bun)
# ===============================
gc() {
  if git diff --cached --quiet; then
    echo "ℹ️  No staged changes to commit."
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
  if [ -f package.json ]; then
    if command -v bun >/dev/null 2>&1; then
      bun run build && bun run test
    elif command -v npm >/dev/null 2>&1; then
      npm run build && npm test
    elif command -v yarn >/dev/null 2>&1; then
      yarn build && yarn test
    fi
  elif [ -f pyproject.toml ] || [ -f setup.py ]; then
    if command -v poetry >/dev/null 2>&1; then
      poetry build && poetry run pytest
    elif command -v hatch >/dev/null 2>&1; then
      hatch build && hatch run test
    else
      python -m build && pytest
    fi
  elif [ -f Cargo.toml ]; then
    cargo build --release && cargo test
  elif [ -f go.mod ]; then
    go build ./... && go test ./...
  elif [ -f pom.xml ]; then
    mvn package -DskipTests && mvn test
  elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
    gradle build -x test && gradle test
  else
    echo "⚠️  No known build system detected."
  fi
}

# ===============================
# Push Helper (with Build/Test)
# ===============================
gpB() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  echo "🏗️  Running build and tests..."
  build_and_test || {
    echo "❌ Build/tests failed. Aborting push."
    return 1
  }
  echo "🚀 Pushing '$branch'..."
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
