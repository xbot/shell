#!/bin/sh

WALLPAPER_DIR="/home/monk/images"
WALLPAPER_LINK="/home/monk/.wallpaper"
WALLPAPER_FILE=`readlink -f "$WALLPAPER_LINK"`

IMG_COUNT=`ls $WALLPAPER_DIR/*.{jpg,png}|wc -l`

while true; do
    RAND=$((RANDOM % IMG_COUNT + 1))
    IMG=`ls $WALLPAPER_DIR/*.{jpg,png}|sed -n ${RAND}p`
    # echo "$IMG" >> ~/log.txt
    # echo ${RAND}/${IMG_COUNT} >> ~/log.txt
    if [[ "$IMG" == "$WALLPAPER_FILE" ]]; then
        continue
    fi

    ln -sf "$IMG" "$WALLPAPER_LINK"
    feh --bg-scale "$WALLPAPER_LINK"
    break
done
