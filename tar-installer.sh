#!/bin/bash

GAME_DIR_NAME="$1"
if [[ -z "$GAME_DIR_NAME" ]]; then
  echo "Usage: $0 GAME_DIR_NAME"
  exit 1
fi

GAME_DIR="$HOME/windows_games/setups/$GAME_DIR_NAME"
if [[ ! -d "$GAME_DIR" ]]; then
  echo "Could not find folder $GAME_DIR"
  exit 1
fi

mkdir -p ~/windows_games/tars
cd ~/windows_games/tars
# If no compression option was chosen, default to no compression
if [[ -z "$GZIP" ]]; then
  GZIP=-1
fi
export GZIP # Export GZIP for use in tar
time tar -czvf "$GAME_DIR_NAME.tar.gz" -C "$GAME_DIR" .
