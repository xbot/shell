#!/bin/bash
# A manager for all proxy scripts in the folder "proxy".
# Author: Donie Leigh <donie.leigh@gmail.com>

# gbl_proxy_path=~/.proxies
gbl_proxy_path=`dirname $0`/proxy
gbl_wait_seconds=30

print_help_msg () {
    echo "You see, I'm nothing ..."
    exit 0
}
touch_ssh_proxy () {
    l_wait_sec=0
    while tmux list-sessions 2>&1|grep -P "^${gbl_session_name}:.*$" > /dev/null; do
        if lsof -i tcp:"$gbl_local_port" -n|grep ssh > /dev/null 2>&1 ; then
            gbl_finger_print=1
            return
        else
            gbl_finger_print=0
        fi
        sleep 1 && l_wait_sec=$((l_wait_sec+1))
        if [ $l_wait_sec -gt $gbl_wait_seconds ]; then
            l_pid=`ps aux|grep -v grep|grep -P "\stmux\snew-session\s.*\s${gbl_session_name}\s"|awk '{print $2}'`
            test -n $l_pid && kill -9 $l_pid && echo "Session $gbl_session_name killed."
            break
        fi
    done
    gbl_finger_print=-1
}
touch_http_proxy () {
    raw_line=`grep -P "^proxyPort\s*=" $gbl_proxy_conf`
    [ $? -eq -1 ] && echo "Cannot find proxyPort in $gbl_proxy_conf" && exit 1
    http_port=`echo ${raw_line##*=}|tr -d [:space:]`
    if lsof -i tcp:$http_port -n|grep polipo > /dev/null 2>&1 ; then
        gbl_finger_print=1
    else
        gbl_finger_print=0
    fi
}
open_socks () {
    touch_ssh_proxy
    if [ $gbl_finger_print -eq 1 ]; then
        echo 'SOCKS proxy has already been established !'
        return 0
    fi

    echo 'Starting SOCKS proxy ...'
    tmux new-session -d -s "$gbl_session_name" "$gbl_proxy_script"

    touch_ssh_proxy
    if [ $gbl_finger_print -eq -1 ]; then
        echo 'Failed to start socks proxy.'
        return 1
    else
        echo 'SOCKS proxy is started .'
        return 0
    fi
}
close_socks () {
    touch_ssh_proxy
    if [ $gbl_finger_print -eq -1 ]; then
        echo 'SOCKS proxy is not running !'
        return 0
    fi

    killall "${gbl_session_name}.sh"
    test $? -eq 0 && echo 'SOCKS proxy is stopped .' || \
        echo 'Failed to stop SOCKS proxy.' >&2
}
restart_socks () {
    echo 'Restarting SOCKS proxy ...'
    close_socks
    open_socks
}
open_http () {
    touch_http_proxy
    if [ $gbl_finger_print -eq 1 ]; then
        echo 'HTTP proxy has already been established !'
        return 0
    fi

    echo 'Starting HTTP proxy ...'
    tmux new-session -d -s "proxy_http" "polipo -c $gbl_proxy_conf"

    touch_http_proxy
    echo 'HTTP proxy is started .'
}
close_http () {
    touch_http_proxy
    if [ $gbl_finger_print -eq 0 ]; then
        echo 'HTTP proxy is not running !'
        return 0
    fi

    killall polipo
    test $? -eq 0 && echo 'HTTP proxy is stopped .' || \
        echo 'Failed to stop HTTP proxy.' >&2
}
restart_http () {
    echo 'Restarting HTTP proxy ...'
    close_http
    open_http
}
open_bundle () {
    if [ $# -eq 1 ]; then
        ! open_socks $1 && return 1
    else
        ! open_socks && return 1
    fi
    open_http
    return 0
}
close_bundle () {
    close_socks
    close_http
}
restart_bundle () {
    close_http
    close_socks
    open_socks
    open_http
}

l_proxy_name="primary"
l_proxy_type="bundle"
l_action_type=""
while getopts 'hstocr' opt; do
    case $opt in
        h) print_help_msg;exit 0;;
        s) [[ "$l_proxy_type" == "http" ]] && l_proxy_type="bundle" || l_proxy_type="socks";;
        t) [[ "$l_proxy_type" == "socks" ]] && l_proxy_type="bundle" || l_proxy_type="http";;
        o) [[ "$l_action_type" =~ (restart|close) ]] && l_action_type="restart" || l_action_type="open";;
        c) [[ "$l_action_type" =~ (restart|open) ]] && l_action_type="restart" || l_action_type="close";;
        r) l_action_type="restart";;
    esac
done
shift $(($OPTIND - 1))
test $# -gt 0 && l_proxy_name="$1"
test -z $l_action_type && l_action_type="open"

gbl_session_name="ssh_${l_proxy_name}"
gbl_proxy_script="${gbl_proxy_path}/${gbl_session_name}.sh"
gbl_proxy_conf="${gbl_proxy_path}/http_${l_proxy_name}.conf"
gbl_finger_print=0

[[ "$l_proxy_type" =~ (bundle|socks) ]] && ! test -f "$gbl_proxy_script" && echo "$gbl_proxy_script not found." && exit 1
[[ "$l_proxy_type" =~ (bundle|http) ]] && ! test -f "$gbl_proxy_conf" && echo "$gbl_proxy_conf not found." && exit 1
[[ "$l_proxy_type" =~ (bundle|socks) ]] && gbl_local_port=`grep "set l_local_port" "$gbl_proxy_script"|awk '{print $3}'`

eval "${l_action_type}_${l_proxy_type}"
