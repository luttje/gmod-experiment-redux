#!/bin/bash

# Ensure we are relative to the script
cd "$(dirname "$0")"

echo "Compressing all content in the ../content directory"

find ../content -type f -exec bzip2 -k {} \;

echo "Compression complete"
