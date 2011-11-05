#!/bin/bash
# A wrapper of xrandr which sets dualhead displaying up.
# Lenin Lee <lenin.lee@gmail.com>

restart_widget()
{
    killall trayer
    killall cairo-dock

    mytrayer
    cairo-dock &

    tmp=`ps -ef|grep -v grep|grep -w gtim|awk '{ print $2 }'`
    if ! [ -z $tmp ]; then
        kill -9 $tmp
    fi
    gtim &
}

set_dualhead()
{
    xrandr --output LVDS1 --auto
    xrandr --output VGA1 --auto
    xrandr --output VGA1 --right-of LVDS1
    restart_widget
}

set_lvds()
{
    xrandr --output VGA1 --off
    xrandr --output LVDS1 --auto
    restart_widget
}

set_vga()
{
    xrandr --output LVDS1 --off
    xrandr --output VGA1 --auto
    restart_widget
}

if [ $# -eq 0 ]; then
    set_dualhead
    exit
fi

case "$1x" in
    "lvdsx") set_lvds;;
    "vgax") set_vga;;
    *) echo 'Unknown parameter !';;
esac
