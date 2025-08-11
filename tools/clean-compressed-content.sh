#!/bin/bash

# Ensure we are relative to the script
cd "$(dirname "$0")"

echo "Cleaning up compressed content in the ../content directory"

find ../content -type f -name "*.bz2" -exec rm -f {} \;

echo "Cleanup complete"
