#!/bin/bash

echo "Starting local test server..."

if ! curl -s --head http://127.0.0.1:5500/content/ | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null; then
    echo "ERROR: sv_downloadurl is not reachable. We recommend you locally host the content folder for faster downloads."
    exit 1
fi

echo "Starting SRCDS..."

./srcds -console -game garrysmod +maxplayers 20 +gamemode experiment-redux +map rp_c18_v2 +host_workshop_collection 3215035081
