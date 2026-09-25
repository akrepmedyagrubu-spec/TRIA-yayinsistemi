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

    ffmpeg -y -re -i "$FILE" -i "$LOGO" \
    -filter_complex "
    scale=960:540[vid];
    [1:v]scale=960:540[logo];
    [vid][logo]overlay=0:0:format=auto[outv]
    " \
    -map "[outv]" -map 0:a? \
    -c:v libx264 -preset veryfast -tune zerolatency \
    -b:v 700k -maxrate 700k -bufsize 1000k \
    -c:a aac -b:a 96k \
    -f hls \
    -hls_time 2 \
    -hls_list_size 6 \
    -hls_flags delete_segments \
    hls/stream.m3u8

  done < playlist.txt

done
