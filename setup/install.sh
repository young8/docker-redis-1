#!/bin/sh
set -e

REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz

RUNTIME_DEPENDENCIES="su-exec>=0.2"
BUILD_DEPENDENCIES="gcc linux-headers make musl-dev"

apk add --no-cache ${BUILD_DEPENDENCIES} ${RUNTIME_DEPENDENCIES}

addgroup -S redis && adduser -S -G ${REDIS_USER} ${REDIS_USER}

mkdir -p ${REDIS_SETUP_DIR}/src/
cd ${REDIS_SETUP_DIR}/src/
wget -cq ${REDIS_DOWNLOAD_URL} -O ${REDIS_SETUP_DIR}/src/redis-${REDIS_VERSION}.tar.gz
tar -zxf ${REDIS_SETUP_DIR}/src/redis-${REDIS_VERSION}.tar.gz
cd ${REDIS_SETUP_DIR}/src/redis-${REDIS_VERSION}

make && make install

mkdir -p /etc/redis/
cp redis.conf /etc/redis/redis.conf

sed 's/^daemonize yes/daemonize no/' -i /etc/redis/redis.conf
sed 's/^bind 127.0.0.1/bind 0.0.0.0/' -i /etc/redis/redis.conf
sed 's/^# unixsocket \/tmp\/redis.sock/unixsocket \/run\/redis\/redis.sock/' -i /etc/redis/redis.conf
sed 's/^# unixsocketperm 700/unixsocketperm 777/' -i /etc/redis/redis.conf
sed '/^logfile/d' -i /etc/redis/redis.conf

chown -R ${REDIS_USER}:${REDIS_USER} /etc/redis/

mkdir -p /run/redis
chmod -R 0755 /run/redis
chown -R ${REDIS_USER}:${REDIS_USER} /run/redis

mkdir -p ${REDIS_LOG_DIR}
chmod -R 0755 ${REDIS_LOG_DIR}
chown -R ${REDIS_USER}:${REDIS_USER} ${REDIS_LOG_DIR}

apk del ${BUILD_DEPENDENCIES}
rm -rf ${REDIS_SETUP_DIR}/