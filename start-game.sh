#!/bin/bash

# Inputs
export GAME_DIR_NAME="$1"
if [[ -z "$GAME_DIR_NAME" ]]; then
  echo "Usage: ./start-game.sh GAME_DIR_NAME"
  exit 1
fi

./run-script.sh "$GAME_DIR_NAME" "start"
