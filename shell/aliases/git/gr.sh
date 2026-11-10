gr() {
  _grequire "gr <new-branch-name> [old-branch-name]" "$1" || return

  local new_branch old_branch
  new_branch="$1"
  old_branch="${2:-$(_gcurrent)}"

  if [ "$old_branch" = "HEAD" ]; then
    echo "❌ cannot rename detached HEAD."
    return 1
  fi

  echo "✏️  $ git branch -m $old_branch $new_branch"
  git branch -m "$old_branch" "$new_branch" && echo "✅ branch '$old_branch' renamed to '$new_branch'."
}
