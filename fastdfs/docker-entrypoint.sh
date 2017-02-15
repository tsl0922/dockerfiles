#!/usr/bin/env bash

set -eo pipefail
[ $DEBUG ] && set -x

FDFS_BASE_PATH="${FDFS_BASE_PATH:-/fastdfs}"
FDFS_TRACKER_PATH="${FDFS_TRACKER_PATH:-$FDFS_BASE_PATH/tracker}"
FDFS_STORAGE_PATH="${FDFS_STORAGE_PATH:-$FDFS_BASE_PATH/storage}"
FDFS_CONF_PATH="${FDFS_CONF_PATH:-/etc/fdfs}"
NGINX_CONF_PATH="${NGINX_CONF_PATH:-/etc/nginx/nginx.conf}"

FDFS_TRACKER_CONF="$FDFS_CONF_PATH/tracker.conf"
FDFS_STORAGE_CONF="$FDFS_CONF_PATH/storage.conf"
FDFS_MOD_CONF="/etc/fdfs/mod_fastdfs.conf"
FDFS_TRACKER_LOG="$FDFS_TRACKER_PATH/logs/trackerd.log"
FDFS_STORAGE_LOG="$FDFS_STORAGE_PATH/logs/storaged.log"

FDFS_GROUP_NAME="${FDFS_GROUP_NAME:-group0}"
FDFS_TRACKER_SERVER="${FDFS_TRACKER_SERVER:-127.0.0.1:22122}"

# apply tracker conf from env
init_tracker_conf() {
	[ ! -d $FDFS_BASE_PATH ] && mkdir -p $FDFS_BASE_PATH
	[ ! -d $FDFS_TRACKER_PATH ] && mkdir -p $FDFS_TRACKER_PATH
	[ ! -f $FDFS_TRACKER_CONF ] && cp /etc/fdfs/tracker.conf.sample $FDFS_TRACKER_CONF

	sed -i "s#base_path=.*#base_path=$FDFS_TRACKER_PATH#" $FDFS_TRACKER_CONF
}

# apply storage conf from env
init_storage_conf() {
	if [ $FDFS_TRACKER_SERVER = "127.0.0.1:22122" ]; then
		echo "ERROR: FDFS_TRACKER_SERVER env not given"
		exit 1
	fi

	local FDFS_STORE_PATH0="$FDFS_STORAGE_PATH"
	[ ! -d $FDFS_BASE_PATH ] && mkdir -p $FDFS_BASE_PATH
	[ ! -d $FDFS_STORAGE_PATH ] && mkdir -p $FDFS_STORAGE_PATH
	[ ! -d $FDFS_STORE_PATH0 ] && mkdir -p $FDFS_STORE_PATH0
	[ ! -f $FDFS_STORAGE_CONF ] && cp /etc/fdfs/storage.conf.sample $FDFS_STORAGE_CONF

	sed -i "s#base_path=.*#base_path=$FDFS_STORAGE_PATH#" $FDFS_STORAGE_CONF
	sed -i "s#store_path0=.*#store_path0=$FDFS_STORE_PATH0#" $FDFS_STORAGE_CONF
	sed -i "s#group_name=.*#group_name=$FDFS_GROUP_NAME#" $FDFS_STORAGE_CONF
	sed -i "s/tracker_server=.*/tracker_server=$FDFS_TRACKER_SERVER/" $FDFS_STORAGE_CONF

	if [ -f $FDFS_MOD_CONF ]; then
		sed -i "s#base_path=.*#base_path=$FDFS_STORAGE_PATH#" $FDFS_MOD_CONF
		sed -i "s#store_path0=.*#store_path0=$FDFS_STORE_PATH0#" $FDFS_MOD_CONF
		sed -i "s#group_name=.*#group_name=$FDFS_GROUP_NAME#" $FDFS_MOD_CONF
		sed -i "s/tracker_server=.*/tracker_server=$FDFS_TRACKER_SERVER/" $FDFS_MOD_CONF
	fi
}

case "$1" in
bash|sh)
	/bin/bash
	;;
tracker)
	init_tracker_conf

	fdfs_trackerd $FDFS_TRACKER_CONF
	tail -f -n 0 $FDFS_TRACKER_LOG
	;;
storage)
	init_storage_conf

	fdfs_storaged $FDFS_STORAGE_CONF
	(tail -f -n 0 $FDFS_STORAGE_LOG &)
	nginx -g 'daemon off;' -c $NGINX_CONF_PATH
	;;
*)
	[ -n "$1" ] && echo "Unknown command: $1"
	echo "USAGE: $0 tracker|storage"
esac