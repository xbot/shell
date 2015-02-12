#!/bin/bash
######################################################
# Hosts switcher
# 
# Usage:
#     switch_hosts.sh my_group
#
# /etc/hosts format:
#     # == my_group1
#     192.168.1.1 www.my.com
#     # == my_group1
#
#     ## == my_group2
#     #172.16.20.1 www.my.com
#     ## == my_group2
#     
# Author: Donie Leigh <donie.leigh at gmail.com>
######################################################

if [[ -z $1 ]]; then
    echo "Error: Please input a group tag! eg. offline" >&2
    exit 1
fi

HOSTS="/etc/hosts"
HOSTS_TEMP="/tmp/hosts.tmp"
GROUP_TAG="$1"

if ! grep -P "^#[#]? == $GROUP_TAG$" "$HOSTS" > /dev/null; then
    echo "Error: Group $GROUP_TAG not found in $HOSTS" >&2
    exit 1
fi

: > $HOSTS_TEMP

group_weight=0
regex1="^#[#]? == $GROUP_TAG$"
regex2="^#[#]? == [a-zA-Z0-9]+$"

cat $HOSTS | while read line ; do
    if [[ "$line" =~ $regex1 ]]; then
        if [ "$group_weight" -lt 1 ]; then
            if echo "$line" | grep -P "^##" > /dev/null; then
                group_weight=2
            else
                group_weight=1
            fi
        else
            if [ $group_weight == 1 ]; then
                group_weight=3
            elif [ $group_weight == 2 ]; then 
                group_weight=4
            fi
        fi
    elif [[ "$line" =~ $regex2 ]]; then
        if [ "$group_weight" -lt 101 ]; then
            if echo "$line" | grep -P "^##" > /dev/null; then
                group_weight=102
            else
                group_weight=101
            fi
        else
            if [ $group_weight == 101 ]; then
                group_weight=103
            elif [ $group_weight == 102 ]; then 
                group_weight=104
            fi
        fi
    fi
    if [ $group_weight -gt 0 ] && [ $group_weight -lt 100 ]; then
        # uncomment the line if the group has been commented
        if [ $group_weight == 2 ] || [ $group_weight == 4 ]; then
            line=${line/#\#/}
        fi
        if [ $group_weight == 3 ] || [ $group_weight == 4 ]; then
            group_weight=0
        fi
    elif [ $group_weight -gt 100 ] && [ $group_weight -lt 200 ]; then
        # comment the line if the group has not been commented
        if [ $group_weight == 101 ] || [ $group_weight == 103 ]; then
            line="#$line"
        fi
        if [ $group_weight == 103 ] || [ $group_weight == 104 ]; then
            group_weight=0
        fi
    fi

    echo "$line" >> $HOSTS_TEMP
done

cat $HOSTS_TEMP > $HOSTS

rm -rf $HOSTS_TEMP
