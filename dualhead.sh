#!/bin/bash
# A wrapper of xrandr which sets dualhead displaying up.
# Lenin Lee <lenin.lee@gmail.com>

restart_widget()
{
    killall ipager
    killall trayer
    killall cairo-dock
    pid=`ps aux|grep -v grep|grep gtim.py|awk '{print $2}'`
    test -n "$pid" && kill -9 "$pid"

    myipager
    mytrayer
    gtim &
    #cairo-dock &
}

set_dualhead()
{
    xrandr --output LVDS1 --auto
    #xrandr --output VGA1 --auto
    #xrandr --output VGA1 --right-of LVDS1
    xrandr --output HDMI1 --auto
    xrandr --output HDMI1 --right-of LVDS1
    sed -i '/^ipager\.window\.x/ s/[0-9]\+/1366/g' ~/.ipager/ipager.conf
    sed -i '/^ipager\.window\.y/ s/[0-9]\+/1032/g' ~/.ipager/ipager.conf
    restart_widget
}

set_lvds()
{
    xrandr --output VGA1 --off
    xrandr --output HDMI1 --off
    xrandr --output LVDS1 --auto
    sed -i '/^ipager\.window\.x/ s/[0-9]\+/0/g' ~/.ipager/ipager.conf
    sed -i '/^ipager\.window\.y/ s/[0-9]\+/720/g' ~/.ipager/ipager.conf
    restart_widget
}

set_vga()
{
    xrandr --output LVDS1 --off
    xrandr --output VGA1 --auto
    sed -i '/^ipager\.window\.x/ s/[0-9]\+/0/g' ~/.ipager/ipager.conf
    sed -i '/^ipager\.window\.y/ s/[0-9]\+/1032/g' ~/.ipager/ipager.conf
    restart_widget
}

set_hdmi()
{
    xrandr --output LVDS1 --off
    xrandr --output HDMI1 --auto
    sed -i '/^ipager\.window\.x/ s/[0-9]\+/0/g' ~/.ipager/ipager.conf
    sed -i '/^ipager\.window\.y/ s/[0-9]\+/1032/g' ~/.ipager/ipager.conf
    restart_widget
}

if [ $# -eq 0 ]; then
    set_dualhead
    exit
fi

case "$1x" in
    "lvdsx") set_lvds;;
    "vgax") set_vga;;
    "hdmix") set_hdmi;;
    *) echo 'Unknown parameter !';;
esac
