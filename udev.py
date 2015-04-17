#!/usr/bin/env python2
# encoding: utf-8

"""
File:        udev.py
Description: udev monitor script.
Author:      Donie Leigh
Email:       donie.leigh at gmail.com
"""

import glib, os, time
from pyudev import Context, Monitor

PID_FILE = "/tmp/udev_monitor.pid"

def remap_pokerii(device):
    """ Do keyboard remapping when PokerII is plugged in.
    """
    if device.get('ID_VENDOR_ID') == '0f39' \
            and device.action == 'add':
        time.sleep(1)
        os.system('setxkbmap')
        os.system('xmodmap ~/.Xmodmap')

def remap_filco(device):
    """ Do keyboard remapping when Filco is plugged in.
    """
    if device.get('ID_VENDOR_ID') == '04d9' \
            and device.action == 'add':
        time.sleep(1)
        os.system('setxkbmap')
        os.system('xmodmap ~/.Xmodmap')

def is_pid_running(pid):
    """ Check if the given pid is running.

    :pid: int
    :returns: bool

    """
    try:
        os.kill(pid, 0)
    except OSError:
        return False
    return True

def write_pid_or_die():
    """ Write the current pid into pid file or exists if there is already a instance running.

    :returns: void

    """
    if os.path.isfile(PID_FILE):
        pid = int(open(PID_FILE).read())
        if is_pid_running(pid):
            print("Process {0} is still running.".format(pid))
            raise SystemExit
        else:
            os.remove(PID_FILE)

    open(PID_FILE, 'w').write(str(os.getpid()))

def main():
    try:
        from pyudev.glib import MonitorObserver
        def device_event(observer, device):
            remap_pokerii(device)
            remap_filco(device)
    except:
        from pyudev.glib import GUDevMonitorObserver as MonitorObserver
        def device_event(observer, action, device):
            remap_pokerii(device)
            remap_filco(device)

    context = Context()
    monitor = Monitor.from_netlink(context)

    monitor.filter_by(subsystem='usb')
    observer = MonitorObserver(monitor)

    observer.connect('device-event', device_event)
    monitor.start()

    glib.MainLoop().run()

if __name__ == '__main__':
    write_pid_or_die()
    try:
        main()
    except KeyboardInterrupt:
        print("Game over.")
