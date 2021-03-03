#!/bin/bash

# Inputs
export GAME_DIR_NAME="$1"
export GAME_NAME="${2:-$1}"
export SHOULD_SILENCE="y"
if [[ -z "$GAME_DIR_NAME" ]]; then
  echo "\"$GAME_DIR_NAME\" is not a valid game directory"
  exit 1
fi

# Error handling
set -e
export DELETE_IF_BAD=""
export KILL_WINESERVER_IF_BAD=""
err_report() {
  echo "Error ($1)"
  echo "Failed to install $GAME_NAME"
  # Wineserver tries to access GAME_DIR for a while, so kill it before rm'ing GAME_DIR
  if [[ -n "$KILL_WINESERVER_IF_BAD" ]]; then
    as-windows-games-user wineserver -k
  fi
  if [[ -n "$DELETE_IF_BAD" ]]; then
    as-windows-games-user rm -r "$GAME_DIR"
  fi
}
trap 'err_report $LINENO' ERR

# Create Silence output fd's
if [[ "$SHOULD_SILENCE" =~ ^[yY](es)?$ ]]; then
  # Redirect 1/2 into /dev/null
  exec 3>/dev/null
  exec 4>/dev/null
else
  # Redirect 1/2 back into themselves
  exec 3>&1
  exec 4>&2
fi
# Add "1>&3 2>&4" to any installation commands that should potentially be silenced

# Check for setup directory
cd ../setups
if [[ ! -d "./$GAME_DIR_NAME" ]]; then
  echo "Could not find directory ./$GAME_DIR_NAME"
  exit 1
fi

# Setup game directory
if [[ ! -d "$HOME/windows_games/games" ]]; then
  echo "~/windows_games/games directory not found. Please run ~/windows_games/setups/main-setup.sh first"
  exit 1
fi
GAME_DIR="$HOME/windows_games/games/$GAME_DIR_NAME"
export HOME="$HOME/windows_games/games" # To ensure that as-windows-games-user never gets passed /home/$CALLING_USER
if [[ -d "$GAME_DIR" || -f "$GAME_DIR" ]]; then
  echo "Game directory $GAME_DIR already exists! Delete? (y/n)"
  echo "(WARNING: THIS WILL DELETE ALL GAME DATA FOR $GAME_NAME)"
  read -rp "" input
  if [[ "$input" =~ ^[yY](es)?$ ]]; then
    echo "Deleting $GAME_DIR..."
    as-windows-games-user rm -r "$GAME_DIR"
    echo "Deleted!"
    echo
  else
    echo "Cannot install as long as $GAME_DIR exists."
    exit 1
  fi
fi
DELETE_IF_BAD="y" # Since the old game dir is no more, we're safe to delete it if our setup script crashes

# Populate and set the home directory
as-windows-games-user mkdir "$GAME_DIR" "$GAME_DIR/home" "$GAME_DIR/home/Documents" "$GAME_DIR/home/Downloads" "$GAME_DIR/home/Videos" "$GAME_DIR/home/Pictures" "$GAME_DIR/home/Music" "$GAME_DIR/home/Templates"
export HOME="$GAME_DIR/home" # Set to the correct new home

# Give WindowsGamesUser full permissions to the installer directory
setfacl -R -m u:WindowsGamesUser:rwX "./$GAME_DIR_NAME"
# And then relative symlink the installer directory into the game directory
as-windows-games-user ln -s "../../setups/$GAME_DIR_NAME" "$GAME_DIR/installer"

# Initialize wine
export WINEPREFIX="$GAME_DIR/wine"
export WINEARCH="win32"
export WINEDLLOVERRIDES="mscoree,mshtml,winemenubuilder.exe=" # Silence mono/gecko popups
KILL_WINESERVER_IF_BAD="y"
as-windows-games-user mkdir -p "$HOME/.config/pulse"
as-windows-games-user tee "$HOME/.config/pulse/client.conf" >/dev/null <<EOF
autospawn = no
default-server = unix:/tmp/shared-pulse-socket
EOF
as-windows-games-user wineboot --init 1>&3 2>&4

cd "$GAME_DIR/installer"
as-windows-games-user ./setup.sh

# Remove installer symlink
as-windows-games-user rm "$GAME_DIR/installer"

# But keep start.sh
as-windows-games-user cp "../../setups/$GAME_DIR_NAME/start.sh" "$GAME_DIR/start.sh"

echo "Install Complete!"
echo "Simply run ./start.sh $GAME_DIR_NAME to start $GAME_NAME, enjoy!"

