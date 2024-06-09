#!/bin/bash

#
# This script will clean up the specified folders by removing the oldest files
# until the total size of the folder is under the limit.
# We use it to clean up the recordings folder of the voice-server plugin.
#
# To set it up:
#
# 1. Clone the repository to /srv/experiment-redux.
#
# 2. Make the script executable:
#    chmod +x /srv/experiment-redux/tools/cleanup.sh
#
# 3. Add the following line to the crontab:
#    */15 * * * * /srv/experiment-redux/tools/cleanup.sh
#
#    This will run the script every 15 minutes.
#

cleanup_folder() {
    local folder=$1
    local max_size=4G
    local current_size

    # Calculate current size of the folder
    current_size=$(du -sh "$folder" | cut -f1)

    if [[ $current_size > $max_size ]]; then
        echo "Cleaning up $folder, current size: $current_size"

        # Find and remove the oldest files until the size is under the limit
        while [[ $(du -sh "$folder" | cut -f1) > $max_size ]]; do
            oldest_file=$(find "$folder" -type f -printf '%T+ %p\n' | sort | head -n 1 | awk '{print $2}')
            if [[ -n $oldest_file ]]; then
                rm "$oldest_file"
                echo "Removed $oldest_file"
            else
                echo "No more files to remove in $folder"
                break
            fi
        done
    else
        echo "$folder is under the size limit, current size: $current_size"
    fi
}

# List of folders to clean up
folders=(
    "/srv/experiment-redux/plugins/external_moderation/voice-server/recordings/untranscribed/"
    "/srv/experiment-redux/plugins/external_moderation/voice-server/recordings/transcribed/"
)

for folder in "${folders[@]}"; do
    cleanup_folder "$folder"
done
