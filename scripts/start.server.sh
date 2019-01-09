#!/bin/bash

DAEMON=/usr/local/shadowsocks/ssserver
CONF=/etc/shadowsocks/ssserver.json
PID_FILE=/var/run/ssserver.pid

$DAEMON -u -c $CONF 2>&1 > /dev/null &
PID=$!
echo $PID > $PID_FILE
sleep 0.3