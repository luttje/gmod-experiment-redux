#!/bin/bash

output="$1" # where to save the result

voice="en_UK/apope_low"

mkdir -p /root/.local/share/mycroft/mimic3/

/home/mimic3/app/.venv/bin/mimic3 --ssml --voice "$voice" > /root/.local/share/mycroft/mimic3/output.wav

ffmpeg -y -i /root/.local/share/mycroft/mimic3/output.wav -filter_complex "[0:a]rubberband=pitch=2[a];[a]apsyclip=clip=0.2:iterations=10:adaptive=1[b];[b]rubberband=pitch=0.49[c];[c]asuperstop=centerf=500[d];[d]loudnorm=I=-12:LRA=5[e];[e]apad=pad_dur=3[f];[f]aecho=0.7:0.4:1000|500:0.1|0.05[out]" -map "[out]" /root/.local/share/mycroft/mimic3/$output
