#!/bin/bash
# A wrapper of xrandr which sets dualhead displaying up.
# Author: Donie Leigh <donie.leigh@gmail.com>

start_ipager()
{
    sleep_time=0
    if [ $# -eq 1 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
        sleep_time=$1
    fi

    sleep $sleep_time && ipager &
}
start_trayer()
{
    trayer --transparent true --widthtype request --align right --alpha 220 &
}
restart_widgets()
{
    killall ipager
    killall trayer
    killall volumeicon
    #killall cairo-dock
    pid=`ps aux|grep -v grep|grep gtim.py|awk '{print $2}'`
    test -n "$pid" && kill -9 "$pid"

    start_ipager 3
    start_trayer
    gtim &
    volumeicon &
    #cairo-dock &
}

set_dualhead()
{
    #xrandr --output VGA1 --auto
    #xrandr --output VGA1 --right-of LVDS1
    #xrandr --output HDMI1 --left-of LVDS1
    # xrandr --output VGA1 --auto --pos 0x0
    xrandr --output HDMI1 --auto --pos 1366x0
    xrandr --output LVDS1 --auto --pos 0x0
    # xrandr --output HDMI1 --auto --pos 1920x312
    #sed -i '/^ipager\.window\.x/ s/[0-9]\+/0/g' ~/.ipager/ipager.conf
    #sed -i '/^ipager\.window\.y/ s/[0-9]\+/1032/g' ~/.ipager/ipager.conf
    #restart_widgets
}
set_lvds()
{
    # xrandr --output VGA1 --off
    xrandr --output HDMI1 --off
    xrandr --output LVDS1 --auto
    # sed -i '/^ipager\.window\.x/ s/[0-9]\+/0/g' ~/.ipager/ipager.conf
    # sed -i '/^ipager\.window\.y/ s/[0-9]\+/720/g' ~/.ipager/ipager.conf
    #restart_widgets
}
set_vga()
{
    xrandr --output LVDS1 --off
    xrandr --output VGA1 --auto
    sed -i '/^ipager\.window\.x/ s/[0-9]\+/0/g' ~/.ipager/ipager.conf
    sed -i '/^ipager\.window\.y/ s/[0-9]\+/1032/g' ~/.ipager/ipager.conf
    #restart_widgets
}
set_hdmi()
{
    xrandr --output LVDS1 --off
    xrandr --output HDMI1 --auto
    sed -i '/^ipager\.window\.x/ s/[0-9]\+/0/g' ~/.ipager/ipager.conf
    sed -i '/^ipager\.window\.y/ s/[0-9]\+/1032/g' ~/.ipager/ipager.conf
    #restart_widgets
}

handle_startup()
{
    monitors=`xrandr -q|grep -w connected|awk '{print $1}'`
    monitors=($monitors)
    for m in ${monitors[@]}; do
        [[ "$m" == "HDMI1" ]] && set_hdmi
        [[ "$m" == "VGA1" ]] && set_vga
    done
}

if [ $# -eq 0 ]; then
    set_dualhead
    exit
fi

cmd=""
while getopts 'lrvdc:s' opt; do
    case $opt in
        l) set_lvds;shift;;
        r) set_hdmi;shift;;
        v) set_vga;shift;;
        d) set_dualhead;shift;;
        c) cmd=$OPTARG;shift 2;;
        s) handle_startup;shift;;
        *) echo 'Unknown param !' >&2;;
    esac
done

case "$cmd" in
    "refresh") restart_widgets;;
    "ipager") start_ipager "$@";;
    "trayer") start_trayer;;
    "") ;;
    *) echo 'Unknown command !' >&2;;
esac
