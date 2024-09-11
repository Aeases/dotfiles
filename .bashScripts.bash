#!/bin/bash
ccg () { gcc ./$1 -o $1.bin && ./$1.bin; rm "$1.bin" }

gifMe () {mkdir -p /tmp/gifMeImages/; rm /tmp/gifMeImages/*.png; ffmpeg -i $1 -vf scale=320:-1 -r 30 /tmp/gifMeImages/ffout%3d.png && magick convert -delay 2 -loop 0 /tmp/gifMeImages/ffout*.png ./${1:t:r}.gif }

egpuRun () {__NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json $1}
