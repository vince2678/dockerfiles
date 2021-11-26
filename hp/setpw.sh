#!/bin/sh
PW=`cat /run/secrets/pw`
DEFAULT_PW='password'

if [ -z "$PW" ]; then
    echo "No root password specified, setting to '$DEFAULT_PW'"
    PW=$DEFAULT_PW
fi

passwd <<EOF
$PW
$PW
EOF
