#!/bin/bash
# Move directories, handling conditions when the target already exits
# Author: Donie Leigh <donie.leigh@gmail.com>

OVERWRITE=0
while getopts 'o' OPT; do
    case "$OPT" in
        "o") OVERWRITE=1; shift;;
    esac
done
if [ $# -ne 2 ] || ! [ -d "$1" ] || ([ -e "$2" ] && ! [ -d "$2" ]); then
    echo "Usage: $0 [OPTIONS] SRC_DIR TARGET_DIR" >&2
    exit 1
fi
! test -e "$2" && mv "$1" "$2" && exit 0
if [ $OVERWRITE -eq 1 ]; then
    cp -rf "$1"/. "$2"/ && rm -rf "$1"
else
    cp -rf "$1" "$2" && rm -rf "$1"
fi
