#!/bin/bash

CMD=/usr/bin/unsplash-wallpaper
DIR=/tmp/random-wallpaper-from-unsplash

if [[ ! -x $CMD ]]; then
    echo "unsplash-wallpaper not found" >&2
    exit 1
fi

if [[ ! -d $DIR ]]; then
    mkdir -p $DIR
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
fi

$CMD random -d $DIR
if [[ $? -ne 0 ]]; then
    echo "Failed downloading wallpaper." >&2
    exit 1
fi

mv $DIR/wallpaper-* $HOME/.wallpaper

feh --bg-scale $HOME/.wallpaper
