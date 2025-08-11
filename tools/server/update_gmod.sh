# !/bin/bash

update_server() {
    APP_ID=$1
    DIR=$2

    # Create the directory (if it does not exist already)
    if [ ! -d "$HOME/$DIR" ]; then
        mkdir -p "$HOME/$DIR"
    fi

    # Uh-oh, it looks like we still have no directory. Report an error.
    if [ ! -d "$HOME/$DIR" ]; then
        echo "ERROR! Cannot create directory $HOME/$DIR!"

        # Exit with error status code
        exit 1
    fi

    # Call SteamCMD with the app ID we provided and tell it to install
    /usr/games/steamcmd +force_install_dir "$HOME/$DIR" +login anonymous +app_update $APP_ID validate +quit
}

update_server 4020 "server_1"

exit 0
