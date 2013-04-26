#!/bin/sh

WALLPAPER_DIR="/home/monk/images"
WALLPAPER_LINK="/home/monk/.wallpaper"

IMGS=( `ls $WALLPAPER_DIR/*.{jpg,png}` )
IMG_COUNT=${#IMGS[@]}
RAND=$((RANDOM % IMG_COUNT))
IMG=${IMGS[RAND]}

ln -sf "$IMG" "$WALLPAPER_LINK"
feh --bg-scale "$WALLPAPER_LINK"
