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
# Add --dry-run flag to see what commands would be executed without running them:
#       ./update-workshop-map.sh "Added new area near XCCR" --dry-run

SCRIPT_BASEDIR=$(dirname "$0")
CONFIG_FILE="$SCRIPT_BASEDIR/.env"

# Check for dry-run flag
DRY_RUN=false
if [[ "$*" == *"--dry-run"* ]]; then
    DRY_RUN=true
    echo "DRY RUN MODE - No commands will be executed"
    echo "=========================================="
fi

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

# Remove --dry-run from arguments to get the actual message
ARGS=("$@")
FILTERED_ARGS=()
for arg in "${ARGS[@]}"; do
    if [[ "$arg" != "--dry-run" ]]; then
        FILTERED_ARGS+=("$arg")
    fi
done

if [ ${#FILTERED_ARGS[@]} -eq 0 ]; then
    echo "Error: Update message required as first argument"
    exit 1
fi
UPDATE_MESSAGE="${FILTERED_ARGS[0]}"

rm -f "$SCRIPT_BASEDIR/../workshop-addons/exp_c18/maps/"*.bsp

# Copy the latest bsp file to the workshop-addons/exp_c18 folder
LATEST_BSP=$(ls -t "$SCRIPT_BASEDIR/../maps/exp_c18" | grep exp_c18_v | head -n 1)

# Ask for confirmation before continuing (so we don't pack the wrong bsp)
# VIDE Instructions: https://web.archive.org/web/20250729024922/https://www.tophattwaffle.com/packing-custom-content-using-vide-in-steampipe/
echo "Did you use VIDE to pack the content into $LATEST_BSP?"
read -p "Press enter to continue, or Ctrl+C to cancel"

cp "$SCRIPT_BASEDIR/../maps/exp_c18/$LATEST_BSP" "$SCRIPT_BASEDIR/../workshop-addons/exp_c18/maps/$LATEST_BSP"

# Create the GMA file
echo ""
echo "Creating GMA file..."
"$GM_BIN_PATH/gmad.exe" create -folder "$SCRIPT_BASEDIR/../workshop-addons/exp_c18" -out "$SCRIPT_BASEDIR/../workshop-addons/exp_c18.gma"

GMPUBLISH_CMD="\"$GM_BIN_PATH/gmpublish.exe\" update -id \"$WORKSHOP_ID\" -addon \"$SCRIPT_BASEDIR/../workshop-addons/exp_c18.gma\" -changes \"$UPDATE_MESSAGE\""

# Publish the GMA file to the workshop
if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "The following command would be executed:"
    echo "========================================"
    echo "Publish to workshop:"
    echo "   $GMPUBLISH_CMD"
    echo ""
    echo "DRY RUN COMPLETE - No actual command was executed"
else
    eval "$GMPUBLISH_CMD"
fi
