#!/bin/bash

PIDFILE=/run/openvpn.pid
WS_INIT="/etc/init.d/windscribe-cli"

PID=$(pidof openvpn)

case "$1" in
  start)
    if [ "$($WS_INIT status)" != "Running" ]; then
      $WS_INIT start
    fi

    if [ "$?" -ne 0 ]; then
      exit 1
    fi

    if [ -z "$PID" ]; then
      /usr/bin/windscribe connect
    else
	    rm -f $PIDFILE 2>/dev/null
    fi

    if [ "$?" -ne 0 ]; then
      exit 1
    fi

    pidof openvpn > $PIDFILE
    ;;
  status)
    if [ -n "$PID" ]; then
        echo "Running"
    else
        echo "Stopped"
	exit 1
    fi   

    ;;
  stop)

    /usr/bin/windscribe disconnect
    rm -f $PIDFILE 2>/dev/null

    ;;
  *)
    echo "Usage: $0 {start|stop|status}"
    exit 1
    ;;
esac

exit 0
