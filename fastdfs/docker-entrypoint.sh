#!/usr/bin/env bash

set -eo pipefail
[ $DEBUG ] && set -x

FDFS_BASE_PATH="${FDFS_BASE_PATH:-/fastdfs}"
FDFS_TRACKER_PATH="${FDFS_TRACKER_PATH:-$FDFS_BASE_PATH/tracker}"
FDFS_STORAGE_PATH="${FDFS_STORAGE_PATH:-$FDFS_BASE_PATH/storage}"
FDFS_CONF_PATH="${FDFS_CONF_PATH:-/etc/fdfs}"
NGINX_CONF_PATH="${NGINX_CONF_PATH:-/etc/nginx/nginx.conf}"
NGINX_CACHE_PATH="${NGINX_CACHE_PATH:-/tmp/nginx_cache}"

FDFS_TRACKER_CONF="$FDFS_CONF_PATH/tracker.conf"
FDFS_STORAGE_CONF="$FDFS_CONF_PATH/storage.conf"
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
	local FDFS_STORE_PATH0="$FDFS_STORAGE_PATH"
	[ ! -d $FDFS_BASE_PATH ] && mkdir -p $FDFS_BASE_PATH
	[ ! -d $FDFS_STORAGE_PATH ] && mkdir -p $FDFS_STORAGE_PATH
	[ ! -d $FDFS_STORE_PATH0 ] && mkdir -p $FDFS_STORE_PATH0
	[ ! -f $FDFS_STORAGE_CONF ] && cp /etc/fdfs/storage.conf.sample $FDFS_STORAGE_CONF

	sed -i "s#base_path=.*#base_path=$FDFS_STORAGE_PATH#" $FDFS_STORAGE_CONF
	sed -i "s#store_path0=.*#store_path0=$FDFS_STORE_PATH0#" $FDFS_STORAGE_CONF
	sed -i "s#group_name=.*#group_name=$FDFS_GROUP_NAME#" $FDFS_STORAGE_CONF
	sed -i "s/tracker_server=.*/tracker_server=$FDFS_TRACKER_SERVER/" $FDFS_STORAGE_CONF
}

# apply nginx conf from env
init_nginx_conf() {
	local tracker_host=$(echo $FDFS_TRACKER_SERVER | cut -d':' -f1)
	local tracker_port=$(echo $FDFS_TRACKER_SERVER | cut -d':' -f2)
	sed -i "s/__TRACKER_HOST__/$tracker_host/" $NGINX_CONF_PATH
	sed -i "s/__TRACKER_PORT__/$tracker_port/" $NGINX_CONF_PATH
	sed -i "s#__CACHE_PATH__#$NGINX_CACHE_PATH#" $NGINX_CONF_PATH
	[ ! -d $NGINX_CACHE_PATH ] && mkdir -p $NGINX_CACHE_PATH
	chown -R nginx:nginx $NGINX_CACHE_PATH

	# custom dns resolver for nginx
	if [ -n "$NGINX_RESOLVER" ]; then
		sed -i "s/__RESOLVER__/$NGINX_RESOLVER/" $NGINX_CONF_PATH
	else
		sed -i '/__RESOLVER__/d' $NGINX_CONF_PATH
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
	tail -f -n 0 $FDFS_STORAGE_LOG
	;;
nginx)
	init_nginx_conf

	nginx -g 'daemon off;' -c $NGINX_CONF_PATH
	;;
*)
	[ -n "$1" ] && echo "Unknown command: $1"
	echo "USAGE: $0 tracker|storage|nginx"
esac