#!/bin/bash
set -eo pipefail

# apply SSDB_PORT env
[ -n "$SSDB_PORT" ] && sed -e "s/port:.*/port: $SSDB_PORT/" -i /etc/ssdb.conf

# ssdb-server refuse to start if the pid file already exists
[ -f /run/ssdb.pid ] && rm -f /run/ssdb.pid

/usr/bin/ssdb-server /etc/ssdb.conf