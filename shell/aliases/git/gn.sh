gn() {
  _grequire "gn <new-branch> [base-branch]" "$1" || return

  _gfetch
  _grun "🌱" git switch -c "$1" "${2:-origin/main}"
}
