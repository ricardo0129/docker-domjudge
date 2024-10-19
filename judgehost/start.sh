#!/bin/bash

DOMJUDGE_VERSION="8.2.3"
WORKER_ID=$1 #number (id) of judgehost
SERVER_URL="" #domserver url
WORKER_PASSWORD="" #judgehost user account password in the server

sudo docker run -it --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name judgehost-$(whoami)-$WORKER_ID --hostname judgedaemon-$(whoami)-$WORKER_ID -e DAEMON_ID=$WORKER_ID -e DOMSERVER_BASEURL=$SERVER_URL -e JUDGEDAEMON_PASSWORD=$WORKER_PASSWORD domjudge/judgehost-extended:$DOMJUDGE_VERSION 
