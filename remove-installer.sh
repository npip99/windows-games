#!/bin/bash
set -e

if [[ -z "$1" ]]; then
  echo "Usage: ./remove-installer.sh GAME_DIR_NAME"
  exit 1
fi

DIR="$HOME/windows_games/setups/$1"
if [[ ! -d "$DIR" ]]; then
  echo "Error: $DIR is not a directory"
  exit 1
fi

echo "Warning: ALL DATA in $DIR will be LOST. Continue? (y/n)"
read -rp "" input
if [[ "$input" =~ ^[yY](es)?$ ]]; then
  echo "Deleting $DIR..."
  rm -rf "$DIR"
  echo "Deleted!"
  echo
else
  echo "Deletion cancelled..."
fi
