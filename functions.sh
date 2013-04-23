#!/bin/sh

roar() {
    echo "$@" >&2
}
die() {
    test $# -gt 1 && s="$2" || s=1
    roar "$1" && exit "$s"
}

trim() {
    local var=$1
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}
strip_file_extension() {
    echo ${1%.*}
}
