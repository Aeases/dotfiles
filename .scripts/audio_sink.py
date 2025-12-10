#!/usr/bin/env python3

import subprocess
import json

def get_sinks():
    result = subprocess.run(['pactl', '-f', 'json', 'list', 'sinks'], capture_output=True, text=True);
    return json.loads(result.stdout);

sinks = get_sinks()

sink_dict = {sink['description']: sink['index'] for sink in sinks}

chosen_sink = subprocess.run(['tofi'],input="\n".join(sink_dict.keys()), encoding='utf8', capture_output=True, text=True).stdout.strip("\n");

subprocess.run(['pactl', 'set-default-sink', f'{sink_dict[chosen_sink]}'], encoding='utf8');





