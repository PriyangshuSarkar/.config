#!/bin/bash
# Load environment variables from .env file
# Source this file in your shell: source ~/.config/shell/load-env.sh

set -a
if [ -f ~/.config/.env ]; then
  source ~/.config/.env
else
  echo "Warning: ~/.config/.env not found. Copy from ~/.config/.env.example and add your secrets."
fi
set +a
