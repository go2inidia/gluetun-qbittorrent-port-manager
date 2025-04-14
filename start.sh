#!/bin/bash

COOKIES="/tmp/cookies.txt"
CURRENT_PORT=""

update_port () {
  NEW_PORT=$(cat $PORT_FORWARDED)
  if [ "$NEW_PORT" != "$CURRENT_PORT" ]; then
    CURRENT_PORT=$NEW_PORT
    rm -f $COOKIES
    curl -s -c $COOKIES --data "username=$QBITTORRENT_USER&password=$QBITTORRENT_PASS" ${HTTP_S}://${QBITTORRENT_SERVER}:${QBITTORRENT_PORT}/api/v2/auth/login > /dev/null
    curl -s -b $COOKIES --data 'json={"listen_port": "'"$CURRENT_PORT"'"}' ${HTTP_S}://${QBITTORRENT_SERVER}:${QBITTORRENT_PORT}/api/v2/app/setPreferences > /dev/null
    rm -f $COOKIES
    echo "Successfully updated qbittorrent to port $CURRENT_PORT"
  fi
}

while true; do
  if [ -f $PORT_FORWARDED ]; then
    update_port
    inotifywait -mq -t ${PORT_UPDATE_TIMEOUT:-0} -e close_write $PORT_FORWARDED | while read change; do
      update_port
    done
  else
    echo "Couldn't find file $PORT_FORWARDED"
    echo "Trying again in 10 seconds"
    sleep 10
  fi
done
