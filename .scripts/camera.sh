#!/bin/zsh

#ffplay $(ls /dev/ | grep "video" | xargs -I {} echo "/dev/{}" | tofi)

for dev in `find /dev -iname 'video*' -printf "%f\n"`;do; v4l2-ctl --list-formats --device /dev/$dev | grep -qE '\[[0-9]\]' && echo $dev `cat /sys/class/video4linux/$dev/name`;done | fzf | awk '{ printf("/dev/%s", $1) }' | xargs -I {} ffplay "{}"
