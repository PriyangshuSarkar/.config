# ===============================
# git aliases
# ===============================
ga() { _grun "➕" git add .; }
gs() { _grun "📊" git status -sb; }
gc() { _grun "✏️ " git commit; }
gca() { _grun "✏️ " git commit --amend; }
gu() { _grun "⏪" git reset --soft HEAD~1; }
gstash() { _grun "📦" git stash "$@"; }
gstashp() { _grun "🎁" git stash pop "$@"; }
gl() { _grun "📜" git log --oneline --graph --decorate --all "$@"; }
grl() { _grun "🔄" git reflog --decorate --color=auto "$@"; }
