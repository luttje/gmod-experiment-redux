#!/bin/bash

COMMAND="srcds_run"
PID=$(ps aux | grep "$COMMAND" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
        echo "No process found for command '$COMMAND'. Trying srcds_linux..."
else
        kill $PID
        echo "Process $PID for srcds_run has been terminated."
fi

COMMAND="srcds_linux"
PID=$(ps aux | grep "$COMMAND" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
        echo "No process found for command '$COMMAND'."
else
        kill $PID
        echo "Process $PID for srcds_linux has been terminated."
fi

echo "Stopped by stop_server.sh at $(date)" >> /home/steam/server_launcher.log
echo "=================================" >> /home/steam/server_launcher.log
