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
  echo "🍺 $ brew update && brew upgrade -g && brew cleanup"
  brew update
  brew upgrade -g
  brew cleanup -s
}

tad() {
  echo "💻 $ source ~/.config/shell/dev_tmux.sh"
  source ~/.config/shell/dev_tmux.sh
}

matrix() {
  echo "🟢 $ cmatrix -ba $*"
  command cmatrix -ba "$@"
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

  echo -n "💀 kill tmux session 'dev'? [y/N]: "
  read confirm
  if [[ "$confirm" =~ ^[yY]$ ]]; then
    echo "⚡ $ tmux kill-session -t dev"
    tmux kill-session -t dev && echo "✅ session 'dev' killed."
  else
    echo "🚫 session 'dev' not killed."
  fi
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
  echo "⏪ $ git reset --soft head~1"
  git reset --soft head~1
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
  new_branch="$1"
  old_branch="${2:-$(git rev-parse --abbrev-ref head)}"

  if [ "$old_branch" = "head" ]; then
    echo "❌ cannot rename detached head."
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
  branch="$1"

  echo "🗑️  $ git branch -d $branch"
  if git branch -d "$branch" 2>/dev/null; then
    echo "✅ branch '$branch' deleted safely."
    return 0
  fi

  echo -n "⚠️  safe delete failed. force delete '$branch'? [y/N]: "
  read confirm
  if [[ "$confirm" =~ ^[yY]$ ]]; then
    echo "💥 $ git branch -D $branch"
    git branch -D "$branch" && echo "✅ branch '$branch' force deleted."
  else
    echo "🚫 branch '$branch' not deleted."
  fi
}

gsy() {
  # Ensure inside a git repo
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ not inside a git repository."
    return 1
  fi

  # Detect current branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "❌ not on a branch (detached head)."
    return 1
  fi

  # Optional extra sync target
  extra_branch="$1"

  echo "🔄 $ git fetch --all -p -P"
  git fetch --all -p -P || return 1

  # 1️⃣ Sync with remote self if exists
  if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
    echo "🔁 Merging origin/$branch..."
    git merge "origin/$branch" || {
      echo "❌ merge with origin/$branch failed."
      return 1
    }
  else
    echo "⚠️ No remote branch origin/$branch (skipping self-sync)"
  fi

  # 2️⃣ Determine closest parent branch (or upstream)
  upstream=$(git for-each-ref --format='%(upstream:short)' "refs/heads/$branch")
  if [ -z "$upstream" ]; then
    echo "ℹ️ No upstream set — determining closest parent branch..."
    upstream=$(
      for remote_branch in $(git for-each-ref --format='%(refname:short)' refs/remotes/origin | grep -v "$branch$"); do
        base=$(git merge-base "$branch" "$remote_branch")
        if [ -n "$base" ]; then
          distance=$(git rev-list --count "$base..$branch")
          echo "$distance $remote_branch"
        fi
      done | sort -n | head -1 | awk '{print $2}'
    )
    upstream=${upstream:-origin/main}
  fi

  echo "🔀 Merging closest parent: $upstream..."
  git fetch "${upstream%%/*}" "${upstream#*/}" >/dev/null 2>&1 || true
  git merge "$upstream" || {
    echo "❌ merge with $upstream failed."
    return 1
  }

  # 3️⃣ Merge with the user-specified branch if provided
  if [ -n "$extra_branch" ]; then
    echo "📦 Merging additional branch: $extra_branch..."
    if [[ "$extra_branch" == *"/"* ]]; then
      git fetch "${extra_branch%%/*}" "${extra_branch#*/}" >/dev/null 2>&1 || true
    fi

    if git show-ref --verify --quiet "refs/heads/$extra_branch" ||
      git show-ref --verify --quiet "refs/remotes/$extra_branch"; then
      git merge "$extra_branch" || {
        echo "❌ merge with $extra_branch failed."
        return 1
      }
    else
      echo "⚠️ Branch $extra_branch not found locally or remotely (skipping)"
    fi
  fi

  echo "✅ Branch '$branch' synced successfully."
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
  branch=$(git rev-parse --abbrev-ref head)
  bt || return 1
  echo "🚀 $ git push origin $branch"
  git push origin "$branch"
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
      bun run build && bun run test
    elif command -v npm >/dev/null 2>&1; then
      echo "📦 $ npm run build && npm run test"
      npm run build && npm run test
    elif command -v yarn >/dev/null 2>&1; then
      echo "🧶 $ yarn run build && yarn run test"
      yarn run build && yarn run test
    fi
  # python
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
  # rust
  elif [ -f cargo.toml ]; then
    echo "🦀 $ cargo build --release && cargo test"
    cargo build --release && cargo test
  # go
  elif [ -f go.mod ]; then
    echo "🐹 $ go build ./... && go test ./..."
    go build ./... && go test ./...
  # java (maven/gradle)
  elif [ -f pom.xml ]; then
    echo "☕ $ mvn package -dskiptests && mvn test"
    mvn package -dskiptests && mvn test
  elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
    echo "🐘 $ gradle build -x test && gradle test"
    gradle build -x test && gradle test
  else
    echo "⚠️  no known build system detected — skipping build and tests."
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
