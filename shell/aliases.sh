# Source all alias modules (aliases/*.sh and one level of subfolders, e.g. aliases/git/)
for f in "$HOME/.config/shell/aliases/"*.sh "$HOME/.config/shell/aliases/"*/*.sh; do
  [[ -f "$f" ]] && source "$f"
done
