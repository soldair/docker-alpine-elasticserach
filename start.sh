#!/bin/bash

# uses es home to load all configs.
# adding a "commandopts" to the volume allows you to pass more options to elasticsearch 
# for example heap size. "-Xmx10g -Xms10g"

# production recommendations http://www.elastic.co/guide/en/elasticsearch/guide/current/deploy.html

echo "==============================="
echo "starting elastic search."
echo "==============================="
echo "-------------------------------"
echo "checking ulimits"
echo "-------------------------------"

mapmax=`cat /proc/sys/vm/max_map_count`
filemax=`cat /proc/sys/fs/file-max`

ulimit -a;

echo "fs.file_max: $filemax"
echo "vm.max_map_count: $mapmax"

fds=`ulimit -n`
if [ "$fds" -lt "64000" ] ; then
  echo "ES recommends 64k open files per process. you have "`ulimit -n`
  echo "the docker deamon should be run with increased file descriptors to increase those available in the container"
  echo " try \`ulimit -n 64000\`"
else
  echo "you have more than 64k allowed file descriptors. awesome."
fi

# per user file max

#sysctl -w fs.file-max=100000

#if [ "$mapmax" -lt "262144" ]; then
#  sysctl -w vm.max_map_count=262144
#fi

echo "-------------------------------"
echo "files in volume"
echo "-------------------------------"

vol=/var/lib/elasticsearch

ls $vol

esopts=""
if [ -f "$vol/config/elasticsearch.yml" ]; then
  esopts="-Ees.path.home=$vol";
  echo "setting es.path.home to $vol"
else 
  echo "[WARNING] missing elasticsearch config. not setting es.path.home to $vol"
fi

commandopts=""
if [ -f "/var/lib/elasticsearch/javaopts.sh" ]; then
  commandopts=`cat /var/lib/elasticsearch/commandopts`
fi

echo "-------------------------------"
echo "command opts"
echo "-------------------------------"
echo $commandopts

echo "-------------------------------"
echo "elastic search command"
echo "-------------------------------"

echo "/opt/elasticsearch/bin/elasticsearch $commandopts $esopts"

start() {
 su esrunner -c '/opt/elasticsearch/bin/elasticsearch $commandopts $esopts'
}

start

