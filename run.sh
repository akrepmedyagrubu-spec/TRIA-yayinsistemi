#!/bin/bash

mkdir -p hls

python3 -m http.server 10000 &

while true
do
  while read FILE
  do

    if [[ "$FILE" == *reklam* ]]; then
      LOGO="assets/reklam.png"
    else
      LOGO="assets/yayin.png"
    fi

    ffmpeg -re -i "$FILE" -i "$LOGO" \
    -filter_complex "
    [0:v]scale=960:540[v];
    [1:v]scale=960:540[logo];
    [v][logo]overlay=0:0:format=auto
    " \
    -map "[v]" -map 0:a? \
    -c:v libx264 -preset veryfast -tune zerolatency \
    -r 20 \
    -b:v 650k -maxrate 650k -bufsize 900k \
    -f hls \
    -hls_time 2 \
    -hls_list_size 6 \
    -hls_flags delete_segments+append_list \
    hls/stream.m3u8

  done < playlist.txt
done
