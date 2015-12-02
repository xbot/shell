#!/bin/bash
# Description: Open dir with ROX when usb disks is plugged in.
# Author:      Donie Leigh

export DISPLAY=:0.0
export XAUTHORITY=~/.Xauthority
rox ${2##* } >> /tmp/z.joy 2>&1
