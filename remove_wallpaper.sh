#!/bin/sh
# Remove the current wallpaper
# Author: Donie Leigh <donie.leigh@gmail.com>

WALLPAPER_LINK=~/.wallpaper
WALLPAPER_FILE=`readlink -f "$WALLPAPER_LINK"`
RAND_WALLPAPER_SCRIPT=~/bin/random_wallpaper

error() { # Alert error message
    zenity --error --text="$1"
}
confirm() { # Ask for confirmation
    zenity --question --text="$1"
}

! test -f "$WALLPAPER_LINK" && error "$WALLPAPER_LINK does not exist." && exit 1
! test -f "$WALLPAPER_FILE" && error "$WALLPAPER_FILE does not exist." && exit 1

confirm "Are you sure to delete $WALLPAPER_FILE ?"
if [ $? -eq 0 ]; then
    /bin/rm -f "$WALLPAPER_FILE"
    "$RAND_WALLPAPER_SCRIPT"
fi
