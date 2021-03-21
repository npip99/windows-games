#!/bin/bash
set -e

SETUP_DIR="$HOME/windows_games/setups/$1"

export DELETE_ON_FAIL=""
err_report() {
  echo "Error ($1)"
  echo "Failed to install $GAME_NAME"
  if [[ -n "$DELETE_ON_FAIL" ]]; then
    rm -r "$SETUP_DIR"
  fi
}
trap 'err_report $LINENO' ERR

if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage: ./download.sh GAME_DIR_NAME DOWNLOAD_LINK"
  exit 1
fi

if [[ ! -d "$HOME/windows_games/setups" ]]; then
  echo "Could not find directory $HOME/windows_games/setups. Please run ./main-setup.sh first"
  exit 1
fi

if [[ -d "$SETUP_DIR" || -f "$SETUP_DIR" ]]; then
  echo "$SETUP_DIR already exists! Delete? (y/n)"
  echo "(WARNING: THIS WILL DELETE ALL INSTALLER DATA)"
  read -rp "" input
  if [[ "$input" =~ ^[yY](es)?$ ]]; then
    echo "Deleting $SETUP_DIR..."
    rm -r "$SETUP_DIR"
    echo "Deleted!"
    echo
  else
    echo "Cannot download as long as $SETUP_DIR exists."
    exit 1
  fi
fi

mkdir "$SETUP_DIR"
DELETE_ON_FAIL="true"
curl -L "$2" | tar -xzv -C "$SETUP_DIR" >/dev/null
