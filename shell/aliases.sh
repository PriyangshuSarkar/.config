# ===============================
# general aliases
# ===============================
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'
alias cat='bat'
alias vi='nvim'
alias vim='nvim'

# ===============================
# general functions
# ===============================
brewsync() {
  echo "🍺 $ brew update && brew upgrade -g && brew cleanup --prune=all -s -v"
  brew update
  brew upgrade -g
  brew cleanup --prune=all -s -v
}

tad() {
  echo "💻 $ source ~/.config/shell/dev_tmux.sh"
  source ~/.config/shell/dev_tmux.sh
}

ip() {
  echo "🌍 $ ipinfo myip $*"
  command ipinfo myip "$@"
}

# ===============================
# tmux helper
# ===============================
tkd() {
  if ! tmux has-session -t dev 2>/dev/null; then
    echo "ℹ️  no dev session running"
    return 0
  fi

  local confirm
  echo -n "💀 kill tmux session 'dev'? [y/N]: "
  read -r confirm
  if [[ "$confirm" =~ ^[yY]$ ]]; then
    echo "⚡ $ tmux kill-session -t dev"
    tmux kill-session -t dev && echo "✅ session 'dev' killed."
  else
    echo "🚫 session 'dev' not killed."
  fi
}

# ===============================
# starship theme switcher
# ===============================
starship-catppuccin() {
  echo "🎨 $ cp ~/.config/starship/themes/catppuccin.toml ~/.config/starship.toml"
  cp ~/.config/starship/themes/catppuccin.toml ~/.config/starship.toml &&
    echo "✅ switched to catppuccin theme. restart your shell or run: exec \$SHELL"
}

starship-gruvbox() {
  echo "🎨 $ cp ~/.config/starship/themes/gruvbox.toml ~/.config/starship.toml"
  cp ~/.config/starship/themes/gruvbox.toml ~/.config/starship.toml &&
    echo "✅ switched to gruvbox theme. restart your shell or run: exec \$SHELL"
}

# ===============================
# git helper functions
# ===============================
ga() {
  echo "➕ $ git add ."
  git add .
}

gs() {
  echo "📊 $ git status -sb"
  git status -sb
}

gu() {
  echo "⏪ $ git reset --soft HEAD~1"
  git reset --soft HEAD~1
}

gstash() {
  echo "📦 $ git stash $*"
  git stash "$@"
}

gstashp() {
  echo "🎁 $ git stash pop $*"
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
# git branch functions
# ===============================

gsw() {
  if [ -z "$1" ]; then
    echo "usage: gsw <branch>"
    return 1
  fi
  echo "🔄 $ git fetch --all -p -P"
  git fetch --all -p -P
  echo "🔀 $ git switch $1"
  git switch "$1"
}

gn() {
  if [ -z "$1" ]; then
    echo "usage: gn <new-branch> [base-branch]"
    return 1
  fi

  local new_branch base_branch
  new_branch="$1"
  base_branch="${2:-origin/main}"

  echo "🔄 $ git fetch --all -p -P"
  git fetch --all -p -P
  echo "🌱 $ git switch -c $new_branch $base_branch"
  git switch -c "$new_branch" "$base_branch"
}

gb() {
  if [ "$1" = "-a" ]; then
    echo "🌳 $ git branch -a"
    git branch -a
  else
    echo "🌿 $ git branch"
    git branch
  fi
}

gd() {
  echo "🔸 unstaged changes:"
  echo "👁️  $ git diff --color"
  git diff --color | sed 's/^/    /'
  echo
  echo "🔹 staged changes:"
  echo "👁️  $ git diff --staged --color"
  git diff --staged --color | sed 's/^/    /'
}

gr() {
  if [ -z "$1" ]; then
    echo "usage: gr <new-branch-name> [old-branch-name]"
    return 1
  fi

  local new_branch old_branch
  new_branch="$1"
  old_branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"

  if [ "$old_branch" = "HEAD" ]; then
    echo "❌ cannot rename detached HEAD."
    return 1
  fi

  echo "✏️  $ git branch -m $old_branch $new_branch"
  git branch -m "$old_branch" "$new_branch" && echo "✅ branch '$old_branch' renamed to '$new_branch'."
}

gdel() {
  if [ -z "$1" ]; then
    echo "usage: gdel <branch>"
    return 1
  fi

  local branch confirm
  branch="$1"

  echo "🗑️  $ git branch -d $branch"
  if git branch -d "$branch" 2>/dev/null; then
    echo "✅ branch '$branch' deleted safely."
    return 0
  fi

  echo -n "⚠️  safe delete failed. force delete '$branch'? [y/N]: "
  read -r confirm
  if [[ "$confirm" =~ ^[yY]$ ]]; then
    echo "💥 $ git branch -D $branch"
    git branch -D "$branch" && echo "✅ branch '$branch' force deleted."
  else
    echo "🚫 branch '$branch' not deleted."
  fi
}

_gsy_merge() {
  local target="$1"
  if git show-ref --verify --quiet "refs/heads/$target" ||
    git show-ref --verify --quiet "refs/remotes/$target"; then
    echo "🔁 merging $target..."
    git merge "$target" || {
      echo "❌ merge with $target failed."
      return 1
    }
  else
    echo "⚠️  '$target' not found (skipping)."
  fi
}

gsy() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ not inside a git repository."
    return 1
  }

  local branch remote_branch extra_branch
  branch=$(git rev-parse --abbrev-ref HEAD)

  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "❌ not on a branch (detached HEAD)."
    return 1
  fi

  remote_branch=$(git for-each-ref --format='%(upstream:short)' "refs/heads/$branch")
  extra_branch="$1"

  echo "🔄 $ git fetch --all -p -P"
  git fetch --all -p -P || return 1

  # 1️⃣ sync with remote tracking branch
  if [ -n "$remote_branch" ]; then
    _gsy_merge "$remote_branch" || return 1
  else
    echo "⚠️  no remote tracking branch for '$branch' (skipping)."
  fi

  # 2️⃣ sync with user-specified extra branch
  [ -n "$extra_branch" ] && { _gsy_merge "$extra_branch" || return 1; }

  echo "✅ branch '$branch' synced."
}

# ===============================
# git commit & push helpers
# ===============================
gc() {
  if git diff --cached --quiet; then
    echo "⚠️  no staged changes to commit."
    return 1
  fi

  if command -v bun >/dev/null 2>&1; then
    echo "💬 $ bunx git-cz"
    bunx git-cz || git commit
  else
    echo "💬 $ git commit"
    git commit
  fi
}

gca() {
  echo "✏️  $ git commit --amend"
  git commit --amend
}

gp() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  bt || return 1
  echo "🚀 $ git push origin $branch"
  git push origin HEAD
}

# ===============================
# build & test helper
# ===============================
bt() {
  echo "🔍 detecting build system..."

  # node.js
  if [ -f package.json ]; then
    if command -v bun >/dev/null 2>&1; then
      echo "🥟 $ bun run build && bun run test"
      bun run build && bun run test || return 1
    elif command -v npm >/dev/null 2>&1; then
      echo "📦 $ npm run build && npm run test"
      npm run build && npm run test || return 1
    elif command -v yarn >/dev/null 2>&1; then
      echo "🧶 $ yarn run build && yarn run test"
      yarn run build && yarn run test || return 1
    fi
  # python
  elif [ -f pyproject.toml ] || [ -f setup.py ]; then
    if command -v hatch >/dev/null 2>&1; then
      echo "🐍 $ hatch build && hatch run test"
      hatch build && hatch run test || return 1
    elif command -v poetry >/dev/null 2>&1; then
      echo "📖 $ poetry build && poetry run pytest"
      poetry build && poetry run pytest || return 1
    else
      echo "🐍 $ python -m build && pytest"
      python -m build && pytest || return 1
    fi
  # rust
  elif [ -f Cargo.toml ]; then
    echo "🦀 $ cargo build --release && cargo test"
    cargo build --release && cargo test || return 1
  # go
  elif [ -f go.mod ]; then
    echo "🐹 $ go build ./... && go test ./..."
    go build ./... && go test ./... || return 1
  # java (maven/gradle)
  elif [ -f pom.xml ]; then
    echo "☕ $ mvn package -DskipTests && mvn test"
    mvn package -DskipTests && mvn test || return 1
  elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
    echo "🐘 $ gradle build -x test && gradle test"
    gradle build -x test && gradle test || return 1
  else
    echo "⚠️  no known build system detected — skipping build and tests."
    return 1
  fi

  echo "✅ build and tests passed."
}

# ===============================
# auto-completion for branches
# ===============================
_git_branch_completion() {
  local branches
  branches=($(git for-each-ref --format='%(refname:short)' refs/heads/))
  _arguments "1:branch name:(${branches[*]})"
}

compdef _git_branch_completion gsw gdel gn
