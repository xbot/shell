#!/bin/sh
# Lock screen

if grep Ubuntu /etc/issue > /dev/null 2>&1; then
    gnome-screensaver-command -l
fi
