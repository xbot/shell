#!/bin/bash
# Unzip .zip packages which encoded in GBK
# Prerequisites: 7z, convmv

PKG=$1
DIR=`basename $PKG`
DIR=${DIR%.*}
TMP=`mktemp -d --tmpdir='.' 'unpack.XXXXXX'`
LC_ALL=zh_CN.GBK 7z e $PKG -o$TMP
if [ "$TMP" != "" -a -d "$TMP" ]; then
    cd "$TMP"
    convmv --notest -f gbk -t utf8 *
    cnt=`ls|wc -l`
    [ $cnt -eq 1 ] && mv * .. && cd .. && rmdir "$TMP"
    [ $cnt -gt 1 ] && ! [ -d $DIR ] && cd .. && mv "$TMP" "$DIR" || echo "$DIR already exists or failed renaming the temp dir." >&2
fi
