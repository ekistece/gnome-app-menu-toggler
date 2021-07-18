#!/bin/bash
APP_PATH="/usr/share/applications/"
HOME_APP_PATH="$HOME/.local/share/applications/"

HIDE_APP_LABEL="Hide app icon"
SHOW_APP_LABEL="Show app icon"

hide_apps_menu() {
    while true; do
        declare -A APP_ENTRIES
        for FILENAME in `ls $APP_PATH*.desktop | xargs -n 1 basename`; do
            [ ! -f "$HOME_APP_PATH$FILENAME" ] && IFS=$'\n' APP_ENTRIES["`grep 'Name=' -m 1 $APP_PATH$FILENAME | cut -d '=' -f 2`"]="$FILENAME"
        done
        CHOICE="`zenity --list --title "Hide apps" --column "Shown apps" $(sort <<< "${!APP_ENTRIES[@]}")`"
        [ $? -eq 1 ] && return
        FILENAME="${APP_ENTRIES[$CHOICE]}"
        cp "$APP_PATH$FILENAME" "$HOME_APP_PATH"
        echo "Hidden=true" >> "$HOME_APP_PATH$FILENAME"
        unset APP_ENTRIES
    done
}

show_apps_menu() { 
    while true; do
        declare -A APP_ENTRIES
        for FILENAME in `ls $HOME_APP_PATH*.desktop | xargs -n 1 basename`; do
            grep -e "Hidden=true" "$HOME_APP_PATH$FILENAME" > /dev/null && IFS=$'\n' APP_ENTRIES["`grep 'Name=' -m 1 $HOME_APP_PATH$FILENAME | cut -d '=' -f 2`"]="$FILENAME"
        done
        CHOICE="`zenity --list --title "Unhide apps" --column "Hidden apps" $(sort <<< "${!APP_ENTRIES[@]}")`"
        [ $? -eq 1 ] && return
        FILE_PATH="$HOME_APP_PATH${APP_ENTRIES[$CHOICE]}"
        rm "$FILE_PATH"
        unset APP_ENTRIES
    done
}

while true; do
    CHOICE=`zenity --info --title "GNOME App Toggler" --text "Hide or show apps" --ok-label "Quit" --extra-button "$HIDE_APP_LABEL" --extra-button "$SHOW_APP_LABEL"`
    case $CHOICE in
        $HIDE_APP_LABEL)
            hide_apps_menu
            ;;
        $SHOW_APP_LABEL)
            show_apps_menu
            ;;
        *)
            exit
            ;;
    esac
done
