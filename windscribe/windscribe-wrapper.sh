#!/bin/bash

PIDFILE=/run/openvpn.pid
WS_INIT="/etc/init.d/windscribe-cli"
WINDSCRIBE=`which windscribe`

PID_WS=$(pidof windscribe)
PID_OVPN=$(pidof openvpn)

case "$1" in
  login)
    if [ -z "$PID_WS" ]; then
      rm $WS_PIDFILE
      echo "Starting windscribe..."
      $WS_INIT start
    fi

    if [ "$?" -ne 0 ]; then
      echo "Failed to start windscribe service"
      exit 1
    fi

    $WINDSCRIBE login
    exit $?
    ;;
  start)
    if [ -z "$PID_WS" ]; then
      rm $WS_PIDFILE
      echo "Starting windscribe..."
      $WS_INIT start
    fi

    if [ "$?" -ne 0 ]; then
      echo "Failed to start windscribe service"
      exit 1
    fi

    if [ -z "$PID_OVPN" ]; then
      $WINDSCRIBE connect
    else
	    rm -f $PIDFILE 2>/dev/null
    fi

    if [ "$?" -ne 0 ]; then
      exit 1
    fi

    pidof openvpn > $PIDFILE
    ;;
  status)
    if [ -n "$PID_OVPN" ]; then
        echo "Running"
    else
        echo "Stopped"
	exit 1
    fi   

    ;;
  stop)
    $WINDSCRIBE disconnect
    rm -f $PIDFILE 2>/dev/null
    ;;
  *)
    echo "Usage: $0 {login|start|stop|status}"
    exit 1
    ;;
esac

exit 0
