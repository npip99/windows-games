# Windows Games

This repository may be cloned anywhere, but if you want to keep things all in one place, I recommend the following:

```
mkdir -p ~/windows_games
git clone https://github.com/npip99/windows-games.git ~/windows_games/scripts
# Or,
# git clone git@github.com:npip99/windows-games.git ~/windows_games/scripts
```

# Usage

## Initial setup

Before doing anything else, install WindowsGames by running

```
./main-setup.sh
```

To uninstall, run

```
./main-remove.sh
```

## Installing and running a game

To install a game, do the following:

```
./download.sh GAME_NAME GAME_TARGZ_URL
./install-game.sh GAME_NAME
```

To start the game,

```
./start-game.sh GAME_NAME
```

If you want to clean the unneeded install directory, run

```
./remove-installer.sh GAME_NAME
```

To uninstall the game, run

```
./uninstall-game.sh GAME_NAME
```

# Creating your own game.tar.gz

In `~/windows_games/setups/YOUR_GAME`, you must do the following:
- Add all of your desired installation files in the folder, however you desire
- Add a `./install.sh` for the sequence of commands needed to install the game
- Add a`./start.sh` script that runs the program itself.

The `install.sh` script will have the `$WINEPREFIX` variable passed into it, which can be used to copy local files from the installation directory, to the wine directory. The current working directory of `install.sh`, will be the installation directory with all local files available.

The `./start.sh` script will be have the current working directory of the `$WINEPREFIX` directory itself (And will still have that environment variable passed into it).

In order to save your custom setup into a tar.gz, run `./save.sh YOUR_GAME`, and your tar.gz can then be found in `~/windows_games/saved_setups`. You can then serve that tar.gz from whatever file distribution method you desire. Other users may then use `./download.sh` to download it. NOTE: Do ensure that you follow all trademark and copyright laws for whatever files you choose to distribute. I obviously hold no responsibility for what you choose to distribute on the internet, or what you choose to download from the internet.
