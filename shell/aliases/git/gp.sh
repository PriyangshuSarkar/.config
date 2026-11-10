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

    if ! _gconfirm "🌱 branch '$branch' not found on origin. create it and push?"; then
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
  branches=($(_gbranches))

  for branch in "${branches[@]}"; do
    _GFAIL_REASON=""
    _gp_branch "$branch" 1 ||
      failures+=("$branch|${_GFAIL_REASON:-push failed}")
  done

  _gfail_summary pushed "${failures[@]}"
}

gp() {
  _gin_repo && _gfetch || return 1

  if [ "$1" = "--all" ]; then
    _gp_all
    return
  fi

  _gp_branch "$(_gcurrent)"
}
