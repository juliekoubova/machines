#!/bin/sh
baseurl='rtsp://home.totoro.family'
nozzlecam="${baseurl}:39413/239f28a3f5aaac53"
platecam="${baseurl}:34655/2b2ffc99b34bde00"
topcam="${baseurl}:45629/6ce3b7cd6aa78bdc"
vlc="vlc --loop --no-video-title"
swaymsg "splith; exec ${vlc} '${nozzlecam}'"
sleep 10
swaymsg "exec ${vlc} '${platecam}'"
sleep 10
swaymsg "splitv; exec ${vlc} '${topcam}'"
sleep 10
swaymsg "focus left; splitv; exec foot \"${HOME}/lcd.sh\""
