#!/bin/bash
ccg () { gcc ./$1 -o $1.bin && ./$1.bin; rm "$1.bin"; }

egpuRun () { __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json $1; }

removeNvCache () { rm -r ~/.nv/; rm -r ~/.cache/nvidia/; }
