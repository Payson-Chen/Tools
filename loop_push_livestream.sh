#!/bin/bash

nginx -s reload
rm -rf /opt/homebrew/var/www/hls
mkdir /opt/homebrew/var/www/hls
# 原始图片的路径和名称
loop=$1

path=$2

if [ -z "$1" ]; then
    loop=9999999
else
    echo "use="$loop
fi
echo "loop="$loop


if [ -z "$2" ]; then
    path="/Users/cn22-i570454-a/Movies/1.mp4"
else
    echo "use="$path
fi
echo "path="$path

#counter=1
#
#while [ $counter -le $loop ]
#do
#    ffmpeg -re -i $path -vcodec copy -f flv rtmp://127.0.0.1:1935/hls/room
#    echo "当前loop: $counter"
#    let counter=counter+1
#done


ffmpeg -i https://iot-media-edge1-test.psc.com/hls/monitor/psc-test-00000008-02_1_3.m3u8 \
-c:v copy -an \
-f flv  rtmp://127.0.0.1:1935/hls/room
