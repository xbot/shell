#!/bin/bash
# Kill all processes matching the given keyword, sweet for those started with long commandlines.
# Caution: This script may cause serious problems if abused.

ps aux|grep -v $0|grep -v grep|grep $1

while [ 1 -eq 1 ]; do
    echo
    echo "Kill them all ? (y/N)"
    read order
    case $order in
        n|N|'')
            echo 'Task abandoned.'
            exit
            ;;
        y|Y)
            ps aux|grep -v $0|grep -v grep|grep $1|awk '{ print $2 }'|xargs sudo kill -9
            echo 'Processes killed.'
            exit
            ;;
    esac
done
