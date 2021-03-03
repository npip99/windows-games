# Windows Games

This repository may be cloned anywhere, but if you want to keep things all in one place, I recommend the following:

```
mkdir -p ~/windows_games/scripts
git clone https://github.com/npip99/windows-games.git ~/windows_games/scripts
# Or,
# git clone git@github.com:npip99/windows-games.git ~/windows_games/scripts
```

# Usage

To install a game, do the following:

```
./download.sh GAME_NAME GAME_TARGZ_URL
./setup.sh GAME_NAME
```

To start the game,

```
./start.sh GAME_NAME
```

If you want to clean the unneeded install directory, run

```
./clean.sh GAME_NAME
```

# Creating your own game.tar.gz

In `~/windows_games/setups/YOUR_GAME`, put all your desired installation files in it, and put a `./setup.sh` for the sequence of commands needed to install the game. That script will have the `$WINEPREFIX` variable, which can be used to copy local files from the installation directory, to the wine directory. Additionally, you must add a `./start.sh` that runs the program itself. You can then serve it from whatever file distribution method you desire. Other users may then use `./download.sh` to download it. NOTE: Do ensure that you follow all trademark and copyright laws for whatever files you choose to distribute. I obviously hold no responsibility for what you choose to distribute on the internet, or what you choose to download.
