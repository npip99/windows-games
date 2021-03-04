#!/bin/bash
set -e

if [[ -z "$1" ]]; then
  echo "Usage: ./save-setup.sh GAME_DIR_NAME"
  exit 1
fi

cd "~/windows_games/setups/$1"
mkdir -p "~/windows_games/saved_setups"
tar -czvf "~/windows_games/saved_setups/$1.tar.gz" .
