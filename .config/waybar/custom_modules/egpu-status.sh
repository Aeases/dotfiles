#!/bin/bash
if switcherooctl list 2>/dev/null | grep -qi "nvidia"; then
    echo '{"text": "eGPU ", "class": "active", "tooltip": "eGPU connected"}'
else
    echo '{"text": "", "class": "inactive"}'  # empty = hidden
fi
