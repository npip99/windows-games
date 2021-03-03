#!/bin/bash

ROOT="$HOME/windows_games"
GAMES_DIR="$ROOT/games"

set -e
err_report() {
  echo "Error ($1)"
  echo "Failed to uninstall WindowsGames"
}
trap 'err_report $LINENO' ERR

WINDOWS_GAMES_USERNAME=WindowsGamesUser

# Get sudo password from user before doing anything else
sudo echo "Sudo received!"

echo "Warning: This will delete ALL data across ALL games. Are you sure? (y/n)"
read -rp "" input
if [[ ! "$input" =~ ^[yY](es)?$ ]]; then
  exit 0
fi

# Done first since the ~/games file signifies to ./main-setup.sh that WindowsGames is not installed
sudo rm -rf "$ROOT/games"
sudo rm -rf "$ROOT/setups"
sudo userdel WindowsGamesUser
sudo rm -f /usr/bin/as-windows-games-user
rm -f ~/.config/pulse/default.pa

