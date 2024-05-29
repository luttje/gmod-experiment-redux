#!/bin/bash

#
# This script can be used on the production server to update the experiment-redux repository,
# compress the content and setup permissions for all plugins that require it.
#

cd /srv/experiment-redux
sudo -u www-data git restore .
sudo -u www-data git pull
sudo chmod +x /srv/experiment-redux/tools/compress-content.sh
sudo chmod +x /srv/experiment-redux/tools/discord-process-errors.sh
sudo chmod +x /srv/experiment-redux/plugins/external_moderation/voice-server/start.sh
sudo chmod +x /srv/experiment-redux/plugins/nemesis_ai/voice-generator/start.sh
sudo -u www-data /srv/experiment-redux/tools/compress-content.sh
