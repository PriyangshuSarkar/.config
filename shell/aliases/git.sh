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
gc() { _grun "✏️ " git commit; }
gca() { _grun "✏️ " git commit --amend; }
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

_gsy_rebase() {
  local target="$1"
  echo "🔁 rebasing onto $target..."
  git rebase "$target" || {
    echo "❌ rebase onto $target failed."
    return 1
  }
}

_gsy_branch() {
  local branch remote remote_branch extra_branch
  extra_branch="$1"
  branch=$(git rev-parse --abbrev-ref HEAD)

  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "❌ not on a branch (detached HEAD)."
    return 1
  fi

  remote=$(git remote | head -n 1)

  # 1️⃣ sync with remote tracking branch
  if [ -n "$remote" ]; then
    _gfetch || return 1
    remote_branch="${remote}/${branch}"

    if _gref_exists "$remote_branch"; then
      _gsy_rebase "$remote_branch" || return 1
    else
      echo "⚠️  remote branch '$remote_branch' not found (skipping)."
    fi
  else
    echo "⚠️  no git remote found (skipping remote sync)."
  fi

  # 2️⃣ sync with user-specified extra branch
  if [ -n "$extra_branch" ]; then
    if _gref_exists "$extra_branch"; then
      _gsy_rebase "$extra_branch" || return 1
    else
      echo "⚠️  branch '$extra_branch' not found (skipping)."
    fi
  fi

  echo "✅ branch '$branch' synced."
}

_gsy_all() {
  local extra_branch original_branch branch branches
  extra_branch="$1"
  original_branch=$(git rev-parse --abbrev-ref HEAD)
  branches=($(git for-each-ref --format='%(refname:short)' refs/heads/))

  for branch in "${branches[@]}"; do
    _grun "🔀" git switch "$branch" || {
      echo "⚠️  could not switch to '$branch' (skipping)."
      continue
    }

    _gsy_branch "$extra_branch" || {
      echo "❌ conflict syncing '$branch', aborting rebase..."
      _grun "🧹" git rebase --abort
    }
  done

  _grun "🔀" git switch "$original_branch"
  echo "✅ all branches synced."
}

gsy() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ not inside a git repository."
    return 1
  }

  if [ "$1" = "--all" ]; then
    shift
    _gsy_all "$1"
    return
  fi

  _gsy_branch "$1"
}

# ===============================
# git push helpers
# ===============================

_gp_in_sync() {
  local branch="$1"
  _gref_exists "origin/$branch" || return 1
  [ "$(git rev-parse "$branch")" = "$(git rev-parse "origin/$branch")" ]
}

_gp_branch() {
  local branch="$1" batch="$2"
  _gfetch || return 1

  if _gp_in_sync "$branch"; then
    echo "✅ '$branch' already in sync with origin, skipping push."
    return 0
  fi

  if ! _gref_exists "origin/$branch"; then
    if [ "$batch" = "1" ]; then
      echo "⚠️  '$branch' not found on origin (skipping, run 'gp' on it directly to create)."
      return 0
    fi

    local confirm
    echo -n "🌱 branch '$branch' not found on origin. create it and push? [y/N]: "
    read -r confirm
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
      echo "🚫 push cancelled, '$branch' not created on origin."
      return 1
    fi
  fi

  _grun "🚀" git push origin "$branch"
}

_gp_all() {
  local branch branches
  branches=($(git for-each-ref --format='%(refname:short)' refs/heads/))

  for branch in "${branches[@]}"; do
    _gp_branch "$branch" 1 || echo "⚠️  failed to push '$branch' (skipping)."
  done

  echo "✅ all branches pushed."
}

gp() {
  if [ "$1" = "--all" ]; then
    _gp_all
    return
  fi

  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  _gp_branch "$branch"
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
