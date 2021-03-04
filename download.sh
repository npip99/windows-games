#!/bin/bash
set -e

if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage: ./download.sh GAME_DIR_NAME DOWNLOAD_LINK"
  exit 1
fi

if [[ ! -d "$HOME/windows_games/setups" ]]; then
  echo "Could not find directory $HOME/windows_games/setups. Please run ./main-setup.sh first"
  exit 1
fi

cd "$HOME/windows_games/setups"
if [[ -d "$1" || -f "$1" ]]; then
  echo "$HOME/windows_games/setups/$1 already exists! Please delete it first."
  exit 1
fi
mkdir "$1"
curl -Ls "$2" | tar -xzv -C "./$1"
