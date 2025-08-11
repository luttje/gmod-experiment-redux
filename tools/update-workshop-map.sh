#!/bin/bash

# This script updates the exp_c18_v map on workshop with gmpublish.
# This script is only intended to be run on Windows, by luttje (or someone else with contributor access to the workshop).
#
# 1.    Ensure you have the path to the garrysmod bin directory setup in the .env file.
#
# 2.    Make this script executable:
#       chmod +x ./update-workshop-map.sh
#
# 3.    Run this script with the update message as the first argument, e.g:
#       ./update-workshop-map.sh "Added new area near XCCR"
#

SCRIPT_BASEDIR=$(dirname "$0")
CONFIG_FILE="$SCRIPT_BASEDIR/.env"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

if [ -z "$GM_BIN_PATH" ]; then
    echo "Error: Garry's Mod bin path (GM_BIN_PATH) not found in $CONFIG_FILE"
    exit 1
fi

WORKSHOP_ID="3250002134"

if [ -z "$1" ]; then
    echo "Error: Update message required as first argument"
    exit 1
fi

UPDATE_MESSAGE="$1"

rm -f "$SCRIPT_BASEDIR/../maps/exp_c18/workshop-addon/maps/"*.bsp

# Copy the latest bsp file to the workshop-addon folder
LATEST_BSP=$(ls -t "$SCRIPT_BASEDIR/../maps/exp_c18" | grep exp_c18_v | head -n 1)

# Ask for confirmation before continuing (so we don't pack the wrong bsp)
# VIDE Instructions: https://web.archive.org/web/20250729024922/https://www.tophattwaffle.com/packing-custom-content-using-vide-in-steampipe/
echo "Did you use VIDE to pack the content into $LATEST_BSP?"
read -p "Press enter to continue, or Ctrl+C to cancel"

cp "$SCRIPT_BASEDIR/../maps/exp_c18/$LATEST_BSP" "$SCRIPT_BASEDIR/../maps/exp_c18/workshop-addon/maps/$LATEST_BSP"

# Create the GMA file
"$GM_BIN_PATH/gmad.exe" create -folder "$SCRIPT_BASEDIR/../maps/exp_c18/workshop-addon" -out "$SCRIPT_BASEDIR/../maps/exp_c18/exp_c18.gma"

# Publish the GMA file to the workshop
"$GM_BIN_PATH/gmpublish.exe" update -id "$WORKSHOP_ID" -addon "$SCRIPT_BASEDIR/../maps/exp_c18/exp_c18.gma" -changes "$UPDATE_MESSAGE"
