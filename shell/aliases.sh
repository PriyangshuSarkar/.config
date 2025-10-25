# ===============================
# General aliases
# ===============================
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'
alias vi='nvim'
alias vim='nvim'

# ===============================
# General functions
# ===============================
brewsync() {
  echo "🍺 $ brew update && brew upgrade -g && brew cleanup"
  brew update
  brew upgrade -g
  brew cleanup
}

tad() {
  echo " $ source ~/.config/shell/dev_tmux.sh"
  source ~/.config/shell/dev_tmux.sh
}

cmatrix() {
  echo " $ cmatrix -ba -C cyan $*"
  command cmatrix -ba -C cyan "$@"
}

matrix() {
  echo " $ cmatrix -ba -C cyan $*"
  command cmatrix -ba -C cyan "$@"
}

ip() {
  echo "🌐 $ ipinfo myip $*"
  command ipinfo myip "$@"
}

# ===============================
# Tmux helper
# ===============================
tkd() {
  if ! tmux has-session -t dev 2>/dev/null; then
    echo "ℹ️  No dev session running"
    return 0
  fi

  echo -n "💀 Kill tmux session 'dev'? [y/N]: "
  read confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo " $ tmux kill-session -t dev"
    tmux kill-session -t dev && echo "✅ Session 'dev' killed."
  else
    echo "❌ Session 'dev' not killed."
  fi
}

# ===============================
# Git helper functions
# ===============================
ga() {
  echo " $ git add ."
  git add .
}

gs() {
  echo " $ git status -sb"
  git status -sb
}

gu() {
  echo " $ git reset --soft HEAD~1"
  git reset --soft HEAD~1
}

gstash() {
  echo "📦 $ git stash $*"
  git stash "$@"
}

gstashp() {
  echo "📤 $ git stash pop $*"
  git stash pop "$@"
}

gl() {
  echo "📜 $ git log --oneline --graph --decorate --all $*"
  git log --oneline --graph --decorate --all "$@"
}

grl() {
  echo "🔄 $ git reflog --decorate --color=auto $*"
  git reflog --decorate --color=auto "$@"
}

# ===============================
# Git branch functions
# ===============================

gsw() {
  if [ -z "$1" ]; then
    echo "Usage: gsw <branch>"
    return 1
  fi
  echo "🔄 $ git fetch --all -p -P"
  git fetch --all -p -P
  echo " $ git switch $1"
  git switch "$1"
}

gn() {
  if [ -z "$1" ]; then
    echo "Usage: gn <branch>"
    return 1
  fi
  echo " $ git switch -c $1 origin/main"
  git switch -c "$1" origin/main
}

gb() {
  if [ "$1" = "-a" ]; then
    echo " $ git branch -a"
    git branch -a
  else
    echo " $ git branch"
    git branch
  fi
}

gd() {
  echo "🔹 Unstaged changes:"
  echo " $ git diff --color"
  git diff --color | sed 's/^/    /'
  echo
  echo "🔹 Staged changes:"
  echo " $ git diff --staged --color"
  git diff --staged --color | sed 's/^/    /'
}

gr() {
  if [ -z "$1" ]; then
    echo "Usage: gr <new-branch-name> [old-branch-name]"
    return 1
  fi
  new_branch="$1"
  old_branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"

  if [ "$old_branch" = "HEAD" ]; then
    echo "❌ Cannot rename detached HEAD."
    return 1
  fi

  echo "✏️ $ git branch -m $old_branch $new_branch"
  git branch -m "$old_branch" "$new_branch" && echo "✅ Branch '$old_branch' renamed to '$new_branch'."
}

gdel() {
  if [ -z "$1" ]; then
    echo "Usage: gdel <branch>"
    return 1
  fi
  branch="$1"

  echo "🗑️ $ git branch -d $branch"
  if git branch -d "$branch" 2>/dev/null; then
    echo "✅ Branch '$branch' deleted safely."
    return 0
  fi

  echo -n "⚠️  Safe delete failed. Force delete '$branch'? [y/N]: "
  read confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "💥 $ git branch -D $branch"
    git branch -D "$branch" && echo "✅ Branch '$branch' force deleted."
  else
    echo "❌ Branch '$branch' not deleted."
  fi
}

gsy() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "❌ Not on a branch (detached HEAD)."
    return 1
  fi

  echo "🔄 $ git fetch --all -p -P"
  git fetch --all -p -P || return 1

  if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
    echo "🔀 $ git merge origin/$branch"
    git merge "origin/$branch" || return 1
  else
    echo "⚠️  No remote branch found for $branch, skipping..."
  fi

  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    echo "🔀 $ git merge origin/main"
    git merge origin/main
  else
    echo "❌ origin/main not found"
    return 1
  fi
}

# ===============================
# Git commit & push helpers
# ===============================
gc() {
  if git diff --cached --quiet; then
    echo "⚠️  No staged changes to commit."
    return 1
  fi

  if command -v bun >/dev/null 2>&1; then
    echo "📝 $ bunx git-cz"
    bunx git-cz || git commit
  else
    echo "📝 $ git commit"
    git commit
  fi
}

gp() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  bt || return 1
  echo "🚀 $ git push origin $branch"
  git push origin "$branch"
}

# ===============================
# Build & test helper
# ===============================
bt() {
  echo "🔍 Detecting build system..."

  # Node.js
  if [ -f package.json ]; then
    if command -v bun >/dev/null 2>&1; then
      echo " $ bun run build && bun run test"
      bun run build && bun run test
    elif command -v npm >/dev/null 2>&1; then
      echo "📦 $ npm run build && npm run test"
      npm run build && npm run test
    elif command -v yarn >/dev/null 2>&1; then
      echo "🧶 $ yarn run build && yarn run test"
      yarn run build && yarn run test
    fi
  # Python
  elif [ -f pyproject.toml ] || [ -f setup.py ]; then
    if command -v hatch >/dev/null 2>&1; then
      echo "🐍 $ hatch build && hatch run test"
      hatch build && hatch run test
    elif command -v poetry >/dev/null 2>&1; then
      echo "📖 $ poetry build && poetry run pytest"
      poetry build && poetry run pytest
    else
      echo "🐍 $ python -m build && pytest"
      python -m build && pytest
    fi
  # Rust
  elif [ -f Cargo.toml ]; then
    echo "🦀 $ cargo build --release && cargo test"
    cargo build --release && cargo test
  # Go
  elif [ -f go.mod ]; then
    echo "🐹 $ go build ./... && go test ./..."
    go build ./... && go test ./...
  # Java (Maven/Gradle)
  elif [ -f pom.xml ]; then
    echo "☕ $ mvn package -DskipTests && mvn test"
    mvn package -DskipTests && mvn test
  elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
    echo "🐘 $ gradle build -x test && gradle test"
    gradle build -x test && gradle test
  else
    echo "⚠️  No known build system detected — skipping build and tests."
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

compdef _git_branch_completion gsw gdel gn
