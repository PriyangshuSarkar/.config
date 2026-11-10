# ===============================
# git internal helpers
# ===============================
_grun() {
  local emoji="$1"
  shift
  echo "$emoji \$ $*"
  "$@"
}

_gfetch() {
  _grun "🔄" git fetch --all -p -P
}

_grequire() {
  if [ -z "$2" ]; then
    echo "usage: $1"
    return 1
  fi
}

_gin_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ not inside a git repository."
    return 1
  }
}

_gcurrent() {
  git rev-parse --abbrev-ref HEAD
}

_gbranches() {
  git for-each-ref --format='%(refname:short)' refs/heads/
}

_gref_exists() {
  git show-ref --verify --quiet "refs/heads/$1" ||
    git show-ref --verify --quiet "refs/remotes/$1"
}

# usage: _gconfirm <prompt>  (returns 0 on y/Y)
_gconfirm() {
  local answer
  echo -n "$1 [y/N]: "
  read -r answer
  [[ "$answer" =~ ^[yY]$ ]]
}

# reason for the most recent failure, read by the --all summaries
_GFAIL_REASON=""

# usage: _gfail_summary <verb> <entry>...  (entries are "branch|reason")
_gfail_summary() {
  local verb="$1" entry
  shift
  if [ "$#" -eq 0 ]; then
    echo "✅ all branches $verb."
    return 0
  fi
  echo ""
  echo "❌ $# branch(es) failed:"
  for entry in "$@"; do
    echo "   • ${entry%%|*}: ${entry#*|}"
  done
  return 1
}
