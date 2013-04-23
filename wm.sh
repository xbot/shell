#!/bin/bash
# A wrapper of wmctrl which handles common window-manager's tasks.
# Author: Donie Leigh <donie.leigh@gmail.com>

current_desktop=`wmctrl -d|grep '*'|awk '{ print $1 }'`
desktop_amount=`wmctrl -d|wc -l`
next_desktop=$(((current_desktop+1)%desktop_amount))
prev_desktop=$(((current_desktop-1+desktop_amount)%desktop_amount))
tmp_title=current_window_`date +"%s"`

wm_help()
{
    cat <<"HELP"
Format: wm.sh [ARG [VAL]]

Actions:
    -h:       Print this message.
    -q:       Close the current window.
    -s <L_R>: Switch to the left or right desktop.
    -t <L_R>: Move the current window to the left or right desktop and then switch to it.

Arguments:
    <L_R>: left or right.
HELP
}

if [ $# -eq 0 ]; then wm_help; fi
while getopts 'hqs:t:' opt; do
    case $opt in
        q)
            wmctrl -c :ACTIVE:
            ;;
        s)
            if [ "$OPTARG" = "left" ]; then wmctrl -s $prev_desktop;
            elif [ "$OPTARG" = "right" ]; then wmctrl -s $next_desktop;
            else wm_help; fi
            ;;
        t)
            if [ "$OPTARG" = "left" ]; then wmctrl -r :ACTIVE: -N $tmp_title;wmctrl -r :ACTIVE: -t $prev_desktop;wmctrl -a $tmp_title;
            elif [ "$OPTARG" = "right" ]; then wmctrl -r :ACTIVE: -N $tmp_title;wmctrl -r :ACTIVE: -t $next_desktop;wmctrl -a $tmp_title;
            else wm_help; fi
            ;;
        *)
            wm_help
            ;;
    esac
done
