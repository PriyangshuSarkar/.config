gd() {
  local label emoji flag
  for flag in "" "--staged"; do
    if [ -z "$flag" ]; then
      emoji="🔸"
      label="unstaged"
    else
      echo
      emoji="🔹"
      label="staged"
    fi
    echo "$emoji $label changes:"
    echo "👁️  $ git diff ${flag:+$flag }--color"
    git diff $flag --color | sed 's/^/    /'
  done
}
