#!/bin/bash
# Adjust volume and show the state with OSD

#####################
# Config
CHANNEL='Master'
FONT='10x20'


####################
# Code
action=$1; shift

# Unmute the volume and increase/decrease it
# Arg 1: volume change to set (1+ or 1-)
set_volume() {
    amixer sset $CHANNEL unmute &> /dev/null &
    volume=$(amixer sset $CHANNEL $1 unmute | \
        grep "Mono: Playback" | \
        grep -o "\[[0-9]*%\]" | \
        tr '[%]' ' ')

}

# Get the current volume %
# No args
get_volume() {
    volume=$(amixer sget $CHANNEL | \
        grep "Mono: Playback" | \
        grep -o "\[[0-9]*%\]" | \
        tr '[%]' ' ')
}

# Toggle Master volume mute on/off
# No args
mute_volume() {
    status=$(amixer sset $CHANNEL toggle | \
        grep "Mono: Playback" | \
        grep -o "\[on\]\|\[off\]" | \
        tr '[]' ' ' | \
        tr -d ' ')
}

# Use xosd to show a volume guage on the screen
# Arg 1: Current volume as percent of full volume
# Arg 2: (optional) Text to show above bar
show_volume() {
    killall -9 -q osd_cat &>/dev/null
    osd_cat --font="$FONT" --shadow=1 --color=green --pos=middle --align=center --delay=2 --text "$( [ "z$2" = "z"  ] && echo Volume: $1% || echo $2  )" --barmode=percentage --percentage=$1
}

case "$action" in
    show)
        get_volume
        show_volume $volume 
        ;;

    incr)
        delta=5%+
        set_volume $delta
        show_volume $volume 
        ;;

    decr)
        delta=5%-
        set_volume $delta
        show_volume $volume 
        ;;

    mute)
        mute_volume
        case "$status" in
            off)
                show_volume 0 "Muted"
                ;;
            on)
                get_volume
                show_volume $volume
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 {incr|decr|mute|show}"
        ;;
esac
