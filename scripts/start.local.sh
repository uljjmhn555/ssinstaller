#!/bin/bash

DAEMON=/usr/local/shadowsocks/sslocal
CONF=/etc/shadowsocks/sslocal.json
PID_FILE=/var/run/sslocal.pid

$DAEMON -c $CONF 2>&1 > /dev/null &
PID=$!
echo $PID > $PID_FILE
sleep 0.3