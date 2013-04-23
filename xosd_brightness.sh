#!/bin/bash
# Adjust monitor brightness and show the state with OSD
# Author: Donie Leigh <donie.leigh@gmail.com>

#####################
# Config
BRIGHTNESS_FILE='/sys/class/backlight/acpi_video0/actual_brightness'
MAX_BRIGHTNESS_FILE='/sys/class/backlight/acpi_video0/max_brightness'
FONT='10x20'


####################
# Code
action=$1; shift

# Use xosd to show a brightness guage on the screen
# Arg 1: Current volume as percent of full volume
# Arg 2: (optional) Text to show above bar
show_brightness() {
    ACTUAL_PERCENTAGE=`xbacklight -get|xargs printf "%.0f\n"`
    ACTUAL_LEVEL=`cat $BRIGHTNESS_FILE`
    MAX_LEVEL=`cat $MAX_BRIGHTNESS_FILE`
    killall -9 -q osd_cat &>/dev/null
    osd_cat     --font="$FONT"     --shadow=1     --color=green     --pos=middle     --align=center     --delay=2 --text "$( [ "z$1" = "z"  ] && echo "Brightness: ${ACTUAL_PERCENTAGE}% ($ACTUAL_LEVEL of $MAX_LEVEL)" || echo $1  )"    --barmode=percentage --percentage=$ACTUAL_PERCENTAGE
}

case "$action" in
    show)
        show_brightness
        ;;
    *)
        echo "Usage: $0 {show}"
        ;;
esac
