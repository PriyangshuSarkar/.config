#!/usr/bin/env bash
SESSION="dev"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  # Create session with home window
  tmux new-session -d -s "$SESSION" -n '~' -c ~
  tmux move-window -s "$SESSION:1" -t "$SESSION:3"

  # Create API window
  tmux new-window -t "$SESSION" -n api -c ~/Projects/ops-api

  # Create Web window
  tmux new-window -t "$SESSION" -n web -c ~/Projects/ops-web
fi

# Ensure the session opens on the home window
tmux select-window -t "$SESSION:~"

# Attach to the session
tmux attach -t "$SESSION"
