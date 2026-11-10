gdel() {
  _grequire "gdel <branch>" "$1" || return

  local branch="$1"

  echo "🗑️  $ git branch -d $branch"
  if git branch -d "$branch" 2>/dev/null; then
    echo "✅ branch '$branch' deleted safely."
    return 0
  fi

  if _gconfirm "⚠️  safe delete failed. force delete '$branch'?"; then
    echo "💥 $ git branch -D $branch"
    git branch -D "$branch" && echo "✅ branch '$branch' force deleted."
  else
    echo "🚫 branch '$branch' not deleted."
  fi
}
