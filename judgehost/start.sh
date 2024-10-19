#!/bin/bash

DOMJUDGE_VERSION="8.2.3"
SERVER_ID=$1
WORKER_ID=$2 #number (id) of judgehost
SERVER_URL="" #domserver url
WORKER_PASSWORD="" #judgehost user account password in the server

sudo docker run -it -d --privileged -v /sys/fs/cgroup:/sys/fs/cgroup --name judgehost-$(whoami)-$SERVER_ID-$WORKER_ID --hostname judgedaemon-$(whoami)-$SERVER_ID-$WORKDER_ID -e DAEMON_ID=$WORKER_ID -e DOMSERVER_BASEURL=$SERVER_URL -e JUDGEDAEMON_PASSWORD=$WORKER_PASSWORD domjudge/judgehost-extended:$DOMJUDGE_VERSION-build
