#!/bin/bash
set -m

sed -i "s/MONGODB_ROOT_CA/${MONGODB_ROOT_CA}/g" /configs/mongod.conf
sed -i "s/MONGODB_CERTIFICATE/${MONGODB_CERTIFICATE}/g" /configs/mongod.conf

mongodb_cmd="mongod --storageEngine $STORAGE_ENGINE --bind_ip_all"
cmd="$mongodb_cmd"
if [ "$AUTH" == "yes" ]; then
    cmd="$cmd --port=${MONGODB_PORT} --auth"
fi

if [ "$JOURNALING" == "no" ]; then
    cmd="$cmd --nojournal"
fi

if [ "$OPLOG_SIZE" != "" ]; then
    cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

$cmd &

if [ ! -f /data/db/.mongodb_password_set ]; then
    /set_mongodb_password.sh
fi

if [ "${MONGODB_USE_SSL}" == "true" ]; then
  ps aux | grep -e 'mongod --' | grep -v 'grep' | awk '{print $2}' | xargs kill
  cmd="$cmd --config /configs/mongod.conf"
  sleep 10 && $cmd &
  fg
else
  fg
fi
