#!/bin/sh
baseurl='rtsp://scrypted.totoro.family'
nozzlecam="${baseurl}:55401/00751fdc7ceabb15"
platecam="${baseurl}:55402/829cdb62f9201bf5"
topcam="${baseurl}:55403/3d8a637cc2f64830"
vlc="vlc --loop --no-video-title"
sleep 10
swaymsg "splith; exec ${vlc} '${nozzlecam}'"
sleep 10
swaymsg "exec ${vlc} '${platecam}'"
sleep 10
swaymsg "splitv; exec ${vlc} '${topcam}'"
sleep 10
swaymsg "focus left; splitv; exec foot \"${HOME}/lcd.sh\""
