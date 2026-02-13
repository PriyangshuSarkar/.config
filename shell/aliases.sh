# Source all alias modules
for f in "$HOME/.config/shell/aliases/"*.sh; do
  [[ -f "$f" ]] && source "$f"
done
