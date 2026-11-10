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

# reason for the most recent failure, read by the --all summaries
_GFAIL_REASON=""

# usage: _gfail_summary <verb> <entry>...  (entries are "branch|reason")
_gfail_summary() {
  local verb="$1" entry
  shift
  if [ "$#" -eq 0 ]; then
    echo "✅ all branches $verb."
    return 0
  fi
  echo ""
  echo "❌ $# branch(es) failed:"
  for entry in "$@"; do
    echo "   • ${entry%%|*}: ${entry#*|}"
  done
  return 1
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

_gsy_merge() {
  local target="$1"
  echo "🔁 merging $target..."
  git merge "$target" || {
    echo "❌ merge with $target failed."
    _GFAIL_REASON="merge conflict with $target"
    return 1
  }
}

_gsy_branch() {
  local branch remote remote_branch extra_branch upstream
  extra_branch="$1"
  branch=$(git rev-parse --abbrev-ref HEAD)

  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "❌ not on a branch (detached HEAD)."
    _GFAIL_REASON="not on a branch (detached HEAD)"
    return 1
  fi

  remote=$(git remote | head -n 1)

  # 1️⃣ sync with the branch's own upstream (falls back to guessed remote/branch)
  if [ -n "$remote" ]; then
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name "${branch}@{upstream}" 2>/dev/null)
    remote_branch="${upstream:-${remote}/${branch}}"

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

_gsy_all() {
  local extra_branch original_branch branch branches failures
  failures=()
  extra_branch="$1"
  original_branch=$(git rev-parse --abbrev-ref HEAD)
  branches=($(git for-each-ref --format='%(refname:short)' refs/heads/))

  for branch in "${branches[@]}"; do
    _grun "🔀" git switch "$branch" || {
      echo "⚠️  could not switch to '$branch' (skipping)."
      failures+=("$branch|could not switch (uncommitted changes or checked out elsewhere)")
      continue
    }

    _GFAIL_REASON=""
    _gsy_branch "$extra_branch" || {
      echo "❌ failed syncing '$branch', aborting merge..."
      _grun "🧹" git merge --abort
      failures+=("$branch|${_GFAIL_REASON:-sync failed}")
    }
  done

  _grun "🔀" git switch "$original_branch"
  _gfail_summary synced "${failures[@]}"
}

gsy() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ not inside a git repository."
    return 1
  }

  _gfetch || return 1

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

  if _gp_in_sync "$branch"; then
    echo "✅ '$branch' already in sync with origin, skipping push."
    return 0
  fi

  if ! _gref_exists "origin/$branch"; then
    if [ "$batch" = "1" ]; then
      echo "⚠️  '$branch' not found on origin (skipping, run 'gp' on it directly to create)."
      _GFAIL_REASON="not found on origin (run 'gp' on it directly to create)"
      return 1
    fi

    local confirm
    echo -n "🌱 branch '$branch' not found on origin. create it and push? [y/N]: "
    read -r confirm
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
      echo "🚫 push cancelled, '$branch' not created on origin."
      _GFAIL_REASON="push cancelled, branch not created on origin"
      return 1
    fi
  fi

  local log rc
  log=$(mktemp)
  echo "🚀 \$ git push origin $branch"
  # run under a pty (script) so hook output keeps its colors while still being captured
  if command -v script >/dev/null 2>&1; then
    script -q "$log" git push origin "$branch"
    rc=$?
  else
    git push origin "$branch" >"$log" 2>&1
    rc=$?
    cat "$log"
  fi
  if [ "$rc" -ne 0 ]; then
    echo "⚠️  failed to push '$branch'."
    local clean
    clean=$(sed -E 's/^\^D//; s/\x1b\[[0-9;]*[A-Za-z]//g' "$log" | tr -d '\r\004')
    _GFAIL_REASON=$(echo "$clean" | grep -m1 -E 'rejected|error:|fatal:|FAIL |failed|✖|❌')
    [ -n "$_GFAIL_REASON" ] || _GFAIL_REASON=$(echo "$clean" | grep -v '^[[:space:]]*$' | tail -n 1)
  fi
  rm -f "$log"
  return "$rc"
}

_gp_all() {
  local branch branches failures
  failures=()
  branches=($(git for-each-ref --format='%(refname:short)' refs/heads/))

  for branch in "${branches[@]}"; do
    _GFAIL_REASON=""
    _gp_branch "$branch" 1 ||
      failures+=("$branch|${_GFAIL_REASON:-push failed}")
  done

  _gfail_summary pushed "${failures[@]}"
}

gp() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ not inside a git repository."
    return 1
  }

  _gfetch || return 1

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
