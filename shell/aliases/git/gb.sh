gb() {
  if [ "$1" = "-a" ]; then
    _grun "🌳" git branch -a
  else
    _grun "🌿" git branch
  fi
}
