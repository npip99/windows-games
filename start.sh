#!/bin/bash

# Inputs
export GAME_DIR_NAME="$1"
export GAME_NAME="${2:-$1}"
if [[ -z "$GAME_DIR_NAME" ]]; then
  echo "Usage: ./start.sh GAME_DIR_NAME [GAME_READABLE_NAME]"
  exit 1
fi

# Error handling
set -e
err_report() {
  echo "Error ($1)"
  echo "Failed to start $GAME_NAME"
}
trap 'err_report $LINENO' ERR

# Check for game directory
GAME_DIR="$HOME/windows_games/games/$GAME_DIR_NAME"
if [[ ! -d "$GAME_DIR" ]]; then
  echo "Could not find game directory at games/$GAME_DIR_NAME. Please install $GAME_NAME first."
  exit 1
fi

export HOME="$GAME_DIR/home"
export WINEPREFIX="$GAME_DIR/wine"
export WINEARCH="win32"
cd "$GAME_DIR"
as-windows-games-user ./start.sh

