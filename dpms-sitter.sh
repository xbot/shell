#!/bin/bash
# Baby-sitter of the monitor's DPMS

idle_period=60
ss_switch_off=0
ss_is_off=0

while true; do
    # Read DPMS state
    xset -q|grep "DPMS is Disabled" > /dev/null && ss_is_off=1 || ss_is_off=0
    # Get pid of the current window
    active_window_id=`xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)" | cut -d" " -f5`
    decimal_id=`xprop -id $active_window_id | grep PID | cut -d" " -f3`
    # Traverse all libflashplayer.so
    for pid in `ps -ef|grep -v grep|grep libflashplayer.so|awk '{print $2}'`; do
        # If the current window is libflashplayer.so
        if [ "$pid" -eq "$decimal_id" ]; then
            ss_switch_off=1
            break
        else
            ss_switch_off=0
        fi
    done
    if [ $ss_switch_off -eq 1 ]; then
        # Turn off DPMS
        echo Turn off DPMS
        if [ $ss_is_off -eq 0 ]; then
            echo Action
            xset s off
            xset -dpms
        fi
    else
        # Turn on DPMS
        echo Turn on DPMS
        if [ $ss_is_off -eq 1 ]; then
            echo Action
            xset +dpms
            xset s on
        fi
    fi
    sleep $idle_period
done
