#!/bin/sh
#
# hide the cursor
printf "\e[?25l"
trap 'printf "\e[?25h"; trap - EXIT; exit' EXIT INT HUP

clear

getline() {
  curl -s "http://prusheen-lcd/text_sensor/${1}" | jq -r .value
}

while true; do
  printf "\e[H" # go to 0,0
  getline line_1
  getline line_2
  getline line_3
  getline line_4
  sleep 1
done
