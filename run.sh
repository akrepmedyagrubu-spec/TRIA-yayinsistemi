#!/bin/bash

mkdir -p hls

# HTTP server (Render için)
python3 -m http.server 10000 &

while true
do
  while read line
  do
    FILE="$line"

    # logo seçimi
    if [[ "$FILE" == *"reklam"* ]]; then
      LOGO="assets/reklam.png"
    else
      LOGO="assets/yayin.png"
    fi

    echo "Oynatılıyor: $FILE | Logo: $LOGO"

    ffmpeg -re -i "$FILE" -i "$LOGO" \
    -filter_complex "[1:v]scale=960:540[logo];[0:v]scale=960:540[vid];[vid][logo]overlay=0:0:format=auto" \
    -map 0:v -map 0:a \
    -c:v libx264 -preset veryfast -tune zerolatency \
    -b:v 800k -maxrate 800k -bufsize 1200k \
    -c:a aac -b:a 96k \
    -f hls \
    -hls_time 4 \
    -hls_list_size 5 \
    -hls_flags delete_segments \
    hls/stream.m3u8

  done < playlist.txt
done
