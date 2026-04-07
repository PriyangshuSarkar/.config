#!/usr/bin/env bash
SESSION="dev"
echo "👀 Checking for existing session..."
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "✨ Creating new session: $SESSION"

  # Create session with home window
  tmux new-session -d -s "$SESSION" -n home -c ~
  tmux send-keys -t "$SESSION"
  tmux move-window -s "$SESSION:1" -t "$SESSION:5"

  # Create API window nvim
  echo "🛠️  Setting up API nvim window..."
  tmux new-window -t "$SESSION:1" -n api-nvim -c ~/Projects/ops-api
  tmux split-window -h -t "$SESSION:1.1" -c ~/Projects/ops-api
  tmux send-keys -t "$SESSION:1.1" "nvim" C-m
  tmux send-keys -t "$SESSION:1.2" "claude" C-m
  tmux select-pane -t "$SESSION:1"

  # Create API window terminal
  echo "⚡ Setting up API terminal window..."
  tmux new-window -t "$SESSION:2" -n api-term -c ~/Projects/ops-api
  tmux split-window -v -t "$SESSION:2" -c ~/Projects/ops-api
  tmux send-keys -t "$SESSION:2.1" "bun start:dev" C-m
  tmux select-pane -t "$SESSION:2"

  # Create Web window nvim
  echo "🎨 Setting up Web nvim window..."
  tmux new-window -t "$SESSION:3" -n web-nvim -c ~/Projects/ops-web
  tmux split-window -h -t "$SESSION:3.1" -c ~/Projects/ops-web
  tmux send-keys -t "$SESSION:3.1" "nvim" C-m
  tmux send-keys -t "$SESSION:3.2" "claude" C-m
  tmux select-pane -t "$SESSION:3"

  # Create Web window terminal
  echo "🌐 Setting up Web terminal window..."
  tmux new-window -t "$SESSION:4" -n web-term -c ~/Projects/ops-web
  tmux split-window -v -t "$SESSION:4" -c ~/Projects/ops-web
  tmux send-keys -t "$SESSION:4.1" "bun run dev" C-m
  tmux select-pane -t "$SESSION:4"
fi

# Ensure the session opens on the home window
tmux select-window -t "$SESSION:5"

# Attach to the session
echo "🚀 Attaching to session: $SESSION"
tmux attach -t "$SESSION"
