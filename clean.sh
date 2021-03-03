#!/bin/bash
set -e

if [[ -z "$1" ]]; then
  echo "Usage: ./clean.sh GAME_DIR_NAME"
  exit 1
fi

DIR="$HOME/windows_games/setups/$1"
if [[ ! -d "$DIR" ]]; then
  echo "Error: $DIR is not a directory"
  exit 1
fi
rm -rf "$DIR"
