#!/usr/bin/expect
# An Expect script which establishes an SSH proxy listening port 1080.
# Lenin Lee <lenin.lee@gmail.com>
# HOST:       The SSH server address or hostname.
# LOGIN_NAME: The login name.
# PASSWORD:   The login password.

set timeout 60

spawn /usr/bin/ssh -D 1080 -g LOGIN_NAME@HOST

expect {
    "password:" {
        send "PASSWORD\r"
    }
}

interact {
    timeout 60 {
        send " "
    }
}
