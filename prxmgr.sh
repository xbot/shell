#!/bin/bash
# A manager for all proxy scripts in the folder "proxy".
# Lenin Lee <lenin.lee@gmail.com>

finger_print=0
gbl_proxy_dir=`dirname $0`/proxy
gbl_session_name=ssh_primary
gbl_proxy_script=$gbl_proxy_dir/ssh_primary.sh

print_help_msg () {
    echo "You see, I'm nothing ..."
    exit 0
}

touch_ssh_proxy () {
    # Touch TCP port
    if lsof -i tcp:1080 -n|grep ssh > /dev/null 2>&1 ; then
        finger_print=1
    else
        finger_print=0
    fi

    # Touch session
    if [ $# -eq 1 ]; then
        if ! tmux list-sessions|grep -P "^${1}:.*$" > /dev/null 2>&1; then
            finger_print=-1
        fi
    fi
}

get_session_info () {
    # Refresh session info
    if [ $# -eq 0 ]; then
        touch_ssh_proxy
        if [ $finger_print -eq 1 ]; then
            local session=`tmux list-sessions|grep -P "^ssh_[a-z]+:.*$"|head -n 1|awk '{print $1}'`
            gbl_session_name=${session%:*}
            gbl_proxy_script=$gbl_proxy_dir/$gbl_session_name.sh
        fi
    fi

    # Generate session info
    if [ $# -eq 1 ]; then
        gbl_session_name="ssh_"$1
        gbl_proxy_script=$gbl_proxy_dir/ssh_$1.sh
    fi
}

touch_http_proxy () {
    if lsof -i tcp:2010 -n|grep polipo > /dev/null 2>&1 ; then
        finger_print=1
    else
        finger_print=0
    fi
}

start_socks_proxy () {
    touch_ssh_proxy
    if [ $finger_print -eq 1 ]; then
        echo 'SOCKS proxy has already been established !'
        return 0
    fi

    echo 'Starting SOCKS proxy ...'
    get_session_info $*
    tmux new-session -d -s "$gbl_session_name" "$gbl_proxy_script"

    while [ $finger_print -eq 0 ]; do
        sleep 1
        touch_ssh_proxy $gbl_session_name
    done

    if [ $finger_print -eq -1 ]; then
        echo 'Failed to start socks proxy.'
        return 1
    else
        echo 'SOCKS proxy is started .'
        return 0
    fi
}

stop_socks_proxy () {
    touch_ssh_proxy
    if [ $finger_print -eq 0 ]; then
        echo 'SOCKS proxy is not running !'
        return 0
    fi

    get_session_info $*
    killall "${gbl_session_name}.sh"
    test $? -eq 0 && echo 'SOCKS proxy is stopped .' || \
        echo 'Failed to stop SOCKS proxy.' >&2
}

restart_socks_proxy () {
    echo 'Restarting SOCKS proxy ...'
    stop_socks_proxy
    start_socks_proxy
}

start_http_proxy () {
    touch_http_proxy
    if [ $finger_print -eq 1 ]; then
        echo 'HTTP proxy has already been established !'
        return 0
    fi

    echo 'Starting HTTP proxy ...'
    tmux new-session -d -s "proxy_http" "polipo"

    while [ $finger_print -eq 0 ]; do
        sleep 1
        touch_http_proxy
    done
    echo 'HTTP proxy is started .'
}

stop_http_proxy () {
    touch_http_proxy
    if [ $finger_print -eq 0 ]; then
        echo 'HTTP proxy is not running !'
        return 0
    fi

    killall polipo
    test $? -eq 0 && echo 'HTTP proxy is stopped .' || \
        echo 'Failed to stop HTTP proxy.' >&2
}

restart_http_proxy () {
    echo 'Restarting HTTP proxy ...'
    stop_http_proxy
    start_http_proxy
}

start_proxy_bundle () {
    if [ $# -eq 1 ]; then
        if ! start_socks_proxy $1; then
            return 1
        fi
    else
        if ! start_socks_proxy; then
            return 1
        fi
    fi
    start_http_proxy
    return 0
}

stop_proxy_bundle () {
    stop_socks_proxy
    stop_http_proxy
}

restart_proxy_bundle () {
    stop_http_proxy
    stop_socks_proxy
    start_socks_proxy
    start_http_proxy
}

if [ $# -eq 0 ]; then
    start_proxy_bundle
elif [ $# -eq 1 ]; then
    case "$1x" in
        "onx") start_proxy_bundle;;
        "offx") stop_proxy_bundle;;
        "oox") restart_proxy_bundle;;
        *) start_proxy_bundle $1;;
    esac
elif [ $# -eq 2 ]; then
    if [ "$1x" == "socksx" ]; then
        case "$2x" in
            "onx") start_socks_proxy;;
            "offx") stop_socks_proxy;;
            "oox") restart_socks_proxy;;
            *) start_socks_proxy $1;;
        esac
    elif [ "$1x" == "httpx" ]; then
        case "$2x" in
            "onx") start_http_proxy;;
            "offx") stop_http_proxy;;
            "oox") restart_http_proxy;;
            *) print_help_msg;;
        esac
    else
        print_help_msg
    fi
else
    print_help_msg
fi
