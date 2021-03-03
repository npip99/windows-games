#!/bin/bash

ROOT="$HOME/windows_games"
GAMES_DIR="$ROOT/games"
WINDOWS_GAMES_USERNAME=WindowsGamesUser

set -e
DELETE_GAMES_ON_FAILURE=""
DELETE_USER_ON_FAILURE=""
err_report() {
  echo "Error ($1)"
  echo "Failed to setup WindowsGames"
  if [[ -n "$DELETE_GAMES_ON_FAILURE" ]]; then
    rm -rf "$GAMES_DIR"
  fi
  if [[ -n "$DELETE_USER_ON_FAILURE" ]]; then
    sudo userdel $WINDOWS_GAMES_USERNAME
  fi
}
trap 'err_report $LINENO' ERR

# Get sudo password from user before doing anything else
sudo echo "Sudo received!"

if [[ -d "$GAMES_DIR" ]]; then
  echo "Warning: $GAMES_DIR directory found. Delete? (y/n)"
  echo "(WARNING: THIS WILL DELETE ALL GAME DATA FOR ALL GAMES)"
  read -rp "" input
  if [[ "$input" =~ ^[yY](es)?$ ]]; then
    ./main-remove.sh
    echo "Previous install of WindowsGames deleted"
    echo
  else
    exit 1
  fi
fi
DELETE_GAMES_ON_FAILURE="y"

echo "Installing WindowsGames..."

# Create $WINDOWS_GAMES_USERNAME if he doesn't exist
id -u $WINDOWS_GAMES_USERNAME &>/dev/null || sudo useradd -M -s /bin/bash $WINDOWS_GAMES_USERNAME
DELETE_USER_ON_FAILURE="y"

# Make wrapper that logs in as $WINDOWS_GAMES_USERNAME with X11 permissions
# Use sudo so that root owns the file
sudo gcc as-windows-games-user.c -DHOME_ROOT=\""$GAMES_DIR"\" -Wall -s -O3 -o as-windows-games-user
# Move to /usr/bin
sudo mv as-windows-games-user /usr/bin
# Enable setuid bit so that the executable runs as root
sudo chmod u+s /usr/bin/as-windows-games-user
# Now, allow the current user to execute it
sudo setfacl -m $USER:r-x /usr/bin/as-windows-games-user

# Tell pulseaudio to create a connectable unix socket
PULSEAUDIO_CONFIG="$HOME/.config/pulse/default.pa"
if [[ -f "$PULSEAUDIO_CONFIG" ]]; then
  echo "Custom pulseaudio configuration found at $PULSEAUDIO_CONFIG. Please delete it to continue."
  exit 1
fi
cat >~/.config/pulse/default.pa <<EOF
.include /etc/pulse/default.pa
load-module module-native-protocol-unix auth-anonymous=1 socket=/tmp/shared-pulse-socket
EOF
systemctl --user restart pulseaudio.service

# Give our windows games user the ability to access that socket
setfacl -m u:WindowsGamesUser:rw- /tmp/shared-pulse-socket

# Here we create the games directory
mkdir -p "$ROOT"
mkdir "$GAMES_DIR"
mkdir "$ROOT/setups"
# Have $WINDOWS_GAMES_USERNAME own the games folder
sudo chown $WINDOWS_GAMES_USERNAME "$GAMES_DIR"
# But, allow the current user to access it as well
sudo setfacl -m $USER:rwx "$GAMES_DIR"

# Here, we give WindowsGamesUser the permission to traverse the setups directory
# This is so that it can follow the relative symlink to ~/windows_games/setups/SOME_GAME, where it will have rwx on SOME_GAME
setfacl -m $WINDOWS_GAMES_USERNAME:--X "$ROOT"
setfacl -m $WINDOWS_GAMES_USERNAME:--X "$ROOT/setups"

echo "WindowsGames Installed!"

