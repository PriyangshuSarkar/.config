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
  branch=$(_gcurrent)

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
  original_branch=$(_gcurrent)
  branches=($(_gbranches))

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
  _gin_repo && _gfetch || return 1

  if [ "$1" = "--all" ]; then
    shift
    _gsy_all "$1"
    return
  fi

  _gsy_branch "$1"
}
