#!/bin/bash

mkdir -p hls


python3 -m http.server 10000 &


INPUTS=""
COUNT=0

while read line
do
  FILE=$(echo $line | cut -d"'" -f2)
  INPUTS="$INPUTS -re -i $FILE"
  COUNT=$((COUNT+1))
done < playlist.txt


FILTER=""
CONCAT_INPUT=""

for ((i=0;i<$COUNT;i++))
do
  FILE=$(sed -n "$((i+1))p" playlist.txt | cut -d"'" -f2)

  if [[ "$FILE" == *"reklam"* ]]; then
    FILTER="$FILTER [$i:v]scale=960:540[v$i]; [v$i][${COUNT}:v]overlay=0:0[v${i}o];"
  else
    FILTER="$FILTER [$i:v]scale=960:540[v$i]; [v$i][$(($COUNT+1)):v]overlay=0:0[v${i}o];"
  fi

  CONCAT_INPUT="$CONCAT_INPUT [v${i}o][$i:a]"
done


ffmpeg $INPUTS -i assets/reklam.png -i assets/yayin.png \
-filter_complex "
$FILTER
$CONCAT_INPUT concat=n=$COUNT:v=1:a=1[outv][outa]
" \
-map "[outv]" -map "[outa]" \
-c:v libx264 -preset veryfast -tune zerolatency \
-b:v 800k -maxrate 800k -bufsize 1200k \
-c:a aac -b:a 96k \
-f hls \
-hls_time 2 \
-hls_list_size 6 \
-hls_flags delete_segments+append_list \
hls/stream.m3u8
