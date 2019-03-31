#!/bin/sh



export root_server=`find ~ -name "z2o_server" -type d`

# echo $root_server

ps -fe | grep redis-server | grep -v grep
if [ $? -ne 0 ]
then
    echo "start redis..."
    $root_server/3rd/redis/redis-server $root_server/3rd/redis/redis-development.conf &
else
    echo 'redis already running...'
fi