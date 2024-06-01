#!/bin/bash

# Ensure we are relative to the script
cd "$(dirname "$0")"

echo "Compressing all content in the ../content directory"

find ../content -type f -not -path "../content/nemesis_ai/*" -exec bzip2 -f -k {} \;

echo "Compression complete"
