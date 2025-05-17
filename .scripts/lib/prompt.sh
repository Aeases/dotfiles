#!/bin/sh
#https://youtu.be/R9m723tAurA?t=283
[ $(echo -e "No\nYes" | tofi --text-cursor=false --auto-accept-single=true --hide-input=true --prompt-text="$1" ) \
== "Yes" ] && $2
