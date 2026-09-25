#!/bin/bash

mkdir -p hls

python3 -m http.server 10000 &


FILTER=""

INDEX=0

while read line
do
  FILE=$(echo $line | cut -d"'" -f2)

  if [[ "$FILE" == *"reklam"* ]]; then
    FILTER+="[$INDEX:v][1:v]overlay=0:0[v$INDEX];"
  else
    FILTER+="[$INDEX:v][2:v]overlay=0:0[v$INDEX];"
  fi

  INDEX=$((INDEX+1))
done < playlist.txt


INPUTS=""
INDEX=0

while read line
do
  FILE=$(echo $line | cut -d"'" -f2)
  INPUTS+=" -i $FILE"
  INDEX=$((INDEX+1))
done < playlist.txt

ffmpeg -re $INPUTS -i assets/reklam.png -i assets/yayin.png \
-filter_complex "
$(for i in $(seq 0 $((INDEX-1))); do echo "[$i:v]scale=960:540[v$i];"; done)
$FILTER
$(for i in $(seq 0 $((INDEX-1))); do echo "[v$i]"; done)concat=n=$INDEX:v=1:a=0[outv]
" \
-map "[outv]" \
-map 0:a \
-c:v libx264 -preset veryfast -tune zerolatency \
-b:v 800k -maxrate 800k -bufsize 1200k \
-c:a aac -b:a 96k \
-f hls \
-hls_time 2 \
-hls_list_size 5 \
-hls_flags delete_segments \
hls/stream.m3u8
