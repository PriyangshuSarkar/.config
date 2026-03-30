# ===============================
# git internal helpers
# ===============================
_grun() {
  local emoji="$1"
  shift
  echo "$emoji \$ $*"
  "$@"
}

_gfetch() {
  _grun "🔄" git fetch --all -p -P
}

_grequire() {
  if [ -z "$2" ]; then
    echo "usage: $1"
    return 1
  fi
}

# ===============================
# git helper functions
# ===============================
ga() { _grun "➕" git add .; }
gs() { _grun "📊" git status -sb; }
gu() { _grun "⏪" git reset --soft HEAD~1; }
gstash() { _grun "📦" git stash "$@"; }
gstashp() { _grun "🎁" git stash pop "$@"; }
gl() { _grun "📜" git log --oneline --graph --decorate --all "$@"; }
grl() { _grun "🔄" git reflog --decorate --color=auto "$@"; }

# ===============================
# git branch functions
# ===============================

gsw() {
  _grequire "gsw <branch>" "$1" || return
  _gfetch
  _grun "🔀" git switch "$1"
}

gn() {
  _grequire "gn <new-branch> [base-branch]" "$1" || return

  local new_branch base_branch
  new_branch="$1"
  base_branch="${2:-origin/main}"

  _gfetch
  _grun "🌱" git switch -c "$new_branch" "$base_branch"
}

gb() {
  if [ "$1" = "-a" ]; then
    _grun "🌳" git branch -a
  else
    _grun "🌿" git branch
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
  _grequire "gr <new-branch-name> [old-branch-name]" "$1" || return

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
  _grequire "gdel <branch>" "$1" || return

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

_gref_exists() {
  git show-ref --verify --quiet "refs/heads/$1" ||
    git show-ref --verify --quiet "refs/remotes/$1"
}

_gsy_merge() {
  local target="$1"
  echo "🔁 merging $target..."
  git merge "$target" || {
    echo "❌ merge with $target failed."
    return 1
  }
}

gsy() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ not inside a git repository."
    return 1
  }

  local branch remote remote_branch extra_branch
  branch=$(git rev-parse --abbrev-ref HEAD)

  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "❌ not on a branch (detached HEAD)."
    return 1
  fi

  remote=$(git remote | head -n 1)
  extra_branch="$1"

  # 1️⃣ sync with remote tracking branch
  if [ -n "$remote" ]; then
    _gfetch || return 1
    remote_branch="${remote}/${branch}"

    if _gref_exists "$remote_branch"; then
      _gsy_merge "$remote_branch" || return 1
    else
      echo "⚠️  remote branch '$remote_branch' not found (skipping)."
    fi
  else
    echo "⚠️  no git remote found (skipping remote sync)."
  fi

  # 2️⃣ sync with user-specified extra branch
  if [ -n "$extra_branch" ]; then
    if _gref_exists "$extra_branch"; then
      _gsy_merge "$extra_branch" || return 1
    else
      echo "⚠️  branch '$extra_branch' not found (skipping)."
    fi
  fi

  echo "✅ branch '$branch' synced."
}

# ===============================
# git commit & push helpers
# ===============================
gc() { _grun "💬" git commit "$@"; }

gcx() {
  if git diff --cached --quiet; then
    echo "⚠️  no staged changes to commit."
    return 1
  fi

  if command -v bun >/dev/null 2>&1; then
    echo "💬 $ bunx git-cz"
    bunx git-cz || git commit
  elif command -v npx >/dev/null 2>&1; then
    echo "💬 $ npx git-cz"
    npx git-cz || git commit
  else
    echo "💬 $ git commit"
    git commit
  fi
}

gca() { _grun "✏️ " git commit --amend; }

gp() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  echo "🚀 $ git push origin $branch"
  git push origin HEAD
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
