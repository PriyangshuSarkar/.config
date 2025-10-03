#!/usr/bin/env bash
SESSION="dev"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  # Create API window
  tmux new-session -d -s "$SESSION" -n api -c ~/Projects/ops-api

  # Create Web window
  tmux new-window -t "$SESSION" -n web -c ~/Projects/ops-web

  # Create home directory window
  tmux new-window -t "$SESSION" -n '~' -c ~
fi

tmux attach -t "$SESSION"
