gsw() {
  _grequire "gsw <branch>" "$1" || return
  _gfetch
  _grun "🔀" git switch "$1"
}
