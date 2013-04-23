#!/bin/bash
# VPN profiles manager
# Author: Donie Leigh <donie.leigh@gmail.com>

PROFILE_DIR="/opt/cisco-vpnclient/Profiles"
SCRIPT_DIR=`readlink -f $0|xargs dirname`
source "$SCRIPT_DIR/functions.sh"

print_help_msg () {
    echo "You see, I'm nothing ..."
    exit 0
}

# Handle parameters
PROFILE="default"
ACTION="connect"
while getopts 'hc' opt; do
    case $opt in
        h) print_help_msg; exit 0;;
        c) sudo vpnclient disconnect; exit 0;;
    esac
done
shift $(($OPTIND - 1))
test $# -gt 0 && PROFILE="$1" || PROFILE=`ls -t "$PROFILE_DIR"|head -n 1`; PROFILE=`strip_file_extension "$PROFILE"`
# echo $PROFILE
# echo $ACTION
# exit 1

# Check cisco_ipsec module
lsmod|grep cisco_ipsec > /dev/null || sudo modprobe cisco_ipsec

# Connect the vpn
sudo vpnclient connect "$PROFILE"
