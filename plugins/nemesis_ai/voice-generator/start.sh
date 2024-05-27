#!/bin/bash

#
# This script is run on reboot using crontab to keep the voice generator running
# Should the voice generator crash, this script will restart it up to 20 times
# and log all outputs to a file named with the current date in the ./logs/ directory
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_DIR="$SCRIPT_DIR/logs"
MAX_RESTARTS=20
RESTART_COUNT=0

cd $SCRIPT_DIR

echo "Starting voice generator at $(date)" >> "$LOG_DIR/$(date +%Y-%m-%d).log"

while [ $RESTART_COUNT -lt $MAX_RESTARTS ]; do
  LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"
  docker run -p 3000:3000 --rm -v "/srv/experiment-redux/content/nemesis_ai:/root/.local/share/mycroft/mimic3" --env-file "$SCRIPT_DIR/.env" voice-generator >> "$LOG_FILE" 2>&1
  sleep 1
  ((RESTART_COUNT++))

  echo "Server crashed at $(date); restarting (attempt $RESTART_COUNT/$MAX_RESTARTS)" >> "$LOG_FILE"
done

echo "Server has crashed $MAX_RESTARTS times; check logs for details." >> "$LOG_FILE"
