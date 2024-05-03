#!/bin/bash

# This script checks for errors in clientside and serverside logs and sends them to a Discord webhook.
# You should set it up to run periodically, for example using a cron job:
#
# 1.    This script requires `curl`, `sed`, `grep`, `awk` and `diff` to be installed (they are usually installed by default):
#       sudo apt-get install curl diffutils sed grep gawk
#
# 2.    Make this script executable:
#       chmod +x /srv/experiment-redux/tools/discord-process-errors.sh
#
# 3.    `sudo -u steam crontab -e` and add the following line to run the script every minute:
#       */1 * * * * /srv/experiment-redux/tools/discord-process-errors.sh
#       We run this as the steam user, which is part of the `www-data` group (for /srv/experiment-redux) and has read access to the error files.
#
# 4.    Make sure to set up the Discord webhook config file at `/srv/experiment-redux/tools/.env`
#       with the webhook URL as the content of the file and the paths to the error files.
#       See .env.example for an example.
#       You can create a webhook in Discord by going to Server Settings -> Integrations -> Webhooks.
#

SCRIPT_BASEDIR=$(dirname "$0")
CONFIG_FILE="$SCRIPT_BASEDIR/.env"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Discord webhook config file not found at $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

if [ -z "$WEBHOOK_URL" ]; then
    echo "Error: Discord webhook URL (WEBHOOK_URL) not found in $CONFIG_FILE"
    exit 1
fi

if [ -z "$CLIENTSIDE_ERRORS" ]; then
    echo "Error: Clientside errors file path (CLIENTSIDE_ERRORS) not found in $CONFIG_FILE"
    exit 1
fi

if [ -z "$SERVERSIDE_ERRORS" ]; then
    echo "Error: Serverside errors file path (SERVERSIDE_ERRORS) not found in $CONFIG_FILE"
    exit 1
fi

send_to_discord() {
    local file_type=$1
    local error_message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M")
    local title=":bug: [${file_type^^}] Lua Error occurred"

    # Prefix each line in the error message with > to make it a quote, also ensure newlines are sent as \n
    local description=$(echo -e "${error_message}" | sed 's/^/> /' | sed 's/$/\\n/' | tr -d '\n')
    description="${description}\n\n*On **${file_type^^}**, spotted at ${timestamp}*"

    local color="16711680" # Red for serverside errors

    if [ "$file_type" == "clientside" ]; then
        color="16776960" # Yellow
    fi

    local json_payload=$(cat <<EOF
{
  "content": null,
  "embeds": [
    {
      "title": "${title}",
      "description": "${description}",
      "color": ${color}
    }
  ],
  "attachments": []
}
EOF
)

    response=$(curl -H "Content-Type: application/json" \
         -X POST \
         -d "${json_payload}" \
         "${WEBHOOK_URL}")
    # response='{"message": "The resource is being rate limited.", "retry_after": 0.58, "global": false}'

    # If we're rate limited, wait for a bit over the retry_after time before retrying
    if [[ "$response" == *"retry_after"* ]]; then
        local retry_after=$(echo "$response" | grep -o '"retry_after": [0-9.]*' | grep -o '[0-9]*')
        retry_after=$(echo $retry_after | awk '{print int($1+0.5)}')
        retry_after=$(($retry_after + 1))

        echo "Rate limited, waiting for $retry_after second(s) before retrying..."

        sleep $retry_after
    else
        echo "$response"
    fi
}

process_new_errors() {
    local input_file=$1
    local handled_file="${input_file}.handled"
    local file_type=$2

    touch "${handled_file}"

    # Find new errors not yet handled
    if [ -s "${input_file}" ]; then
        grep -Fxf "${handled_file}" "${input_file}" > /dev/null

        if [ $? -ne 0 ]; then
            # Keep reading lines, starting from [ERROR], until we reach a line with only a carriage return or new line
            error_message=""
            while read line; do
                if [[ "$line" == \[ERROR\]* ]]; then
                    error_message="${error_message}\n${line}"
                elif [[ ! -z "$error_message" ]]; then
                    error_message="${error_message}\n${line}"

                    if [[ "$line" == $'\r' || "$line" == $'\n' ]]; then
                        error_message=$(echo -e "${error_message}" | sed 's/"/\\"/g')
                        send_to_discord "${file_type}" "${error_message}"
                        error_message=""
                    fi
                fi
            done < <(diff --changed-group-format='%>' --unchanged-group-format='' "${handled_file}" "${input_file}")

            # If we have an error message that wasn't sent yet
            if [ ! -z "$error_message" ]; then
                error_message=$(echo -e "${error_message}" | sed 's/"/\\"/g')
                send_to_discord "${file_type}" "${error_message}"
            fi
        fi

        # Update the handled file, so we don't send the same error again
        cp "${input_file}" "${handled_file}"
    fi
}

process_new_errors "${CLIENTSIDE_ERRORS}" "clientside"
process_new_errors "${SERVERSIDE_ERRORS}" "serverside"
