# ===============================
# auto-completion for branches
# ===============================
_git_branch_completion() {
  local branches
  branches=($(_gbranches))
  _arguments "1:branch name:(${branches[*]})"
}

compdef _git_branch_completion gsw gdel gn
